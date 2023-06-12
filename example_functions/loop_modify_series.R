#' @title Exemplo de loop da função de update - Series
#' @author Luiz Paulo T.

rm(list = ls())
dev.off()

# Dependências/Pkgs

library(tidyverse)
library(stringr)
library(stringi)
library(httr)

# Configurando o caminho/diretório do usuário

user = base::getwd() %>%
       stringr::str_extract("^((?:[^/]*/){3})") %>% print()

path <- '4intelligence/Feature Store - Documentos/DRE/Documentação/migracao/'

# Definindo parâmetros do usuário na API - ambiente dev

token_dev = c(
  'Authorization' = 'Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente Stg

token_stg = c(
  'Authorization' = 'Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'XXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_prod = 'https://run-prod-4casthub-featurestore-api-zdfk3g7cpq-ue.a.run.app/'

# Definindo o ambiente ---------------------------------------------------------

ambiente = 'stg' #\ opções: dev, stg, prod

# Configurando a url e token de acordo com o ambiente escolhido

if(ambiente == 'dev') {

  token_to_use = token_dev
  url_to_use = url_dev

} else if (ambiente == 'stg') {

  token_to_use = token_stg
  url_to_use = url_stg

} else if (ambiente == 'prod') {

  token_to_use = token_prod
  url_to_use = url_prod

}

# Metadados --------------------------------------------------------------------

metadados <- readxl::read_excel(paste0(user,
                                       path,
                                       'metadados_migração.xlsx'),
                                skip = 1) %>% janitor::clean_names()

metadados_filt <- metadados %>% 
  #Limpa os indicadores que não serão editados
  filter(descontinuada == 'FALSE') %>% 
  filter(is.na(nao_migrar)) %>% 
  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
  filter(in_fs) %>% 
  pluck('indicator_code') %>% 
  head()

# Unidade ----------------------------------------------------------------------

depara_unidade <- readxl::read_excel(paste0(user, path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

# Chamando a função GET FS-series ----------------------------------------------

sids_in_fs = get_sids(url = url_to_use,
                      token = token_to_use,
                      indicators = metadados_filt) %>%
  dplyr::rename(sids = code)

# Definindo a unidade de medida por SID

metadados_update <- sids_in_fs %>%
                    dplyr::mutate(indicator_code = str_sub(sids, start = 1, end = 9),
                                  regioes = str_sub(sids, start = 10, end = 12),
                                  transfs = str_sub(sids, start = 13, end = 16)) %>%
                    base::merge(metadados, by = "indicator_code") %>%
                    select(indicator_code,
                           regioes,
                           transfs,
                           original_pt,
                           original_en,
                           real_pt,
                           real_en) %>%
                  mutate(cod1_cod2 = paste0(str_sub(transfs, 1,1), str_sub(transfs, 4,4))) %>%
                  left_join(depara_unidade %>%
                            select(cod1_cod2, un_pt, un_en)) %>%
                  rowwise() %>%
                  mutate(un_pt = ifelse(is.na(un_pt),
                                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_pt, real_pt),
                                        un_pt),
                         un_en = ifelse(is.na(un_en),
                                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_en, real_en),
                                        un_en),
                         sid = paste0(indicator_code, regioes, transfs)) %>%
                  dplyr::ungroup()

# Loop -------------------------------------------------------------
# Aplicando update com a função modify_series

for (i in 1:nrow(metadados_update)) {

  # Chamando a função modificação
  modify_series(sid = metadados_update$sid[i],
                units_en = metadados_update$un_en[i],
                units_pt = metadados_update$un_pt[i],
                token = token_to_use,
                url = url_to_use)

}


