#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

library(tidyverse)
library(stringi)
library(httr)


# Definindo parâmetros do usuário - dev  ----------------------------------------------------------

token_dev = c(
  'Authorization' = '',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário - homologação ----------------------------------------------------------

token_homo = c(
  'Authorization' = 'XXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_homo = 'https://4i-featurestore-hmg-api.azurewebsites.net/'

# Definindo parâmetros do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'XXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_prod = ''

ambiente = 'dev' #opções: dev, stg, prod

if(ambiente == 'dev') {
  token_to_use = token_dev
  url_to_use = url_dev
} else if (ambiente == 'stg') {
  token_to_use = token_hmg
  url_to_use = url_hmg
} else if (ambiente == 'prod') {
  token_to_use = token_prod
  url_to_use = url_prod
}

# Carrega metadados -------------------------------------------------------

user <- 'C:/Users/GabrielBelle/'
path <- '4intelligence/Feature Store - Documentos/DRE/Documentação/migracao/'

metadados <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
                                skip = 1) %>% 
  janitor::clean_names()

metadados_filt <- metadados %>% 
  mutate(across(starts_with('description') | contains('_fs'),
                ~ifelse(is.na(.x), "...", .x)),
         name_abv_pt_fs = iconv(name_abv_pt_fs,
                                   from="UTF-8",to="ASCII//TRANSLIT")
         ) %>% 
  mutate(across(starts_with('description'), ~str_replace_all(.x, '"',"'"))) %>% 
  filter(in_fs == F) %>%
  filter(descontinuada == 'FALSE') %>%
  filter(is.na(nao_migrar)) %>%
  filter(str_detect(grupo_4macro, c('Geral'))) %>%
  filter(crawler == 'yahoo_finance')

# Loop de envio de indicadores ------------------------------------------------------------------------------
for (r in 1:nrow(metadados_filt)) {
  
  print(metadados_filt[r,'indicator_code'])
  
  send_indicadores = post.indicator(access_type = "default",
                                    access_group = "Geral",
                                    indicator_code = metadados_filt[r, 'indicator_code'][[1]],
                                    name_en = metadados_filt[r, 'name_en_fs'][[1]],
                                    name_pt = metadados_filt[r, 'name_pt_fs'][[1]],
                                    short_en = metadados_filt[r, 'name_abv_en_fs'][[1]],
                                    short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]],
                                    source_en = metadados_filt[r, 'fonte_fs'][[1]],
                                    source_pt = metadados_filt[r, 'fonte_fs'][[1]],
                                    description_en = metadados_filt[r, 'description_en_fs'][[1]],
                                    description_pt = metadados_filt[r, 'description_pt_fs'][[1]],
                                    description_full_en = metadados_filt[r, 'link_metodologia_fs'][[1]],
                                    description_full_pt = metadados_filt[r, 'link_metodologia_fs'][[1]],
                                    country = str_sub(metadados_filt[r, 'indicator_code'],1,2)[[1]],
                                    sector = str_sub(metadados_filt[r, 'indicator_code'],3,5)[[1]],
                                    node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                                                        ",")[[1]][[1]],
                                    node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                                                        ",")[[1]][[1]],
                                    token = token_to_use,
                                    url = url_to_use)
  
}

