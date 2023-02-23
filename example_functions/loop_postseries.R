#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

# install.packages("devtools")
# devtools::install_github("LuizPaulo023/fsApi", ref = "main")

#library(fsApi)

library(tidyverse)
library(httr)

# Definindo o Token do usuário - homologação ----------------------------------------------------------

token_homo = c(
  'Authorization' = 'Bearer INSIRA O TOKEN DE ACESSO',
  'Content-Type' = 'application/json'
)

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'Bearer INSIRA O TOKEN DE ACESSO',
  'Content-Type' = 'application/json'
)

# Novas Aberturas ---------------------------------------------------------------------------------------

belle_path <- 'C:/Users/GabrielBelle/4intelligence/Feature Store - Documentos/DRE/Documentação/migracao'

indicators_raw <- readxl::read_excel(paste0(belle_path,
                                            '/grupos_transfs_FS.xlsx')) %>% 
  select(codigo, grupo, subgrupo, regioes, starts_with('original_'), starts_with('real_')) %>% 
  mutate(grupo = paste0(grupo, ' - ', subgrupo),
         regioes = ifelse(regioes == '0', '000', regioes))


indicators <- indicators_raw %>% 
  filter(codigo %in% c('BRFXR0015','BRFXR0021','BRFXR0005'))

grupo_transf <- readxl::read_excel(paste0(belle_path, 
                                          '/diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>% 
  pivot_longer(cols = everything(), names_to = 'grupo', values_to = 'transfs') %>% 
  arrange(grupo) %>% 
  filter(!is.na(transfs))

depara_unidade <- readxl::read_excel(paste0(belle_path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida') 

indicators_to_send <- indicators %>% 
  left_join(grupo_transf) %>% 
  mutate(cod1_cod2 = paste0(str_sub(transfs, 1,1),
                            transf_sec = str_sub(transfs, 4,4))) %>% 
  left_join(depara_unidade) %>% 
  rowwise() %>% 
  mutate(un_pt = ifelse(is.na(un_pt),
                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_pt, real_pt),
                        un_pt),
         un_en = ifelse(is.na(un_en),
                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_en, real_en),
                        un_en))

if(any(is.na(indicators_to_send$un_pt)) | any(is.na(indicators_to_send$un_en))) {
  na_un <- indicators_to_send %>% 
    filter(is.na(un_pt) | is.na(un_en)) %>% 
    distinct(codigo) %>% 
    pluck('codigo')
  
  stop(paste0('Os seguintes indicadores não possuem unidade de medida preenchida: ', na_un))
}

for (i in unique(indicators_to_send$codigo)) {
  fsApi::delete_series(indicator = i,
                       token = token_homo)
  
  df_filt <- indicators_to_send %>% 
    filter(codigo == i)
  
  send_transf = post.series(indicator_code = i,
                            region_code = unique(df_filt$regioes),
                            transfs_code = unique(df_filt$transfs),
                            units_en = unique(df_filt$unit_en),
                            units_pt = unique(df_filt$unit_pt),
                            token = token_homo)
  
}


