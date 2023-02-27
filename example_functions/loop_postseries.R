#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

# install.packages("devtools")
# devtools::install_github("LuizPaulo023/fsApi", ref = "main")

library(fsApi)
library(tidyverse)
library(httr)

# Definindo o Token do usuário - homologação ----------------------------------------------------------

token_homo = c(
  'Authorization' = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY3NzUyNTMxMSwiZXhwIjoxNjc3NjExNzExLCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.ZrursNuMafcV33MBgJQg20gFgoT6maTqNkl7WBtuRYd0IlkUbBb2tlw6Yw7cyT9V0SKCv30QEh55hW62NUwir6Ly04xGYJ67wUOdpKJxCVLh91lEIHRQ0D3QPXG7elEWykf0POthVH7vqoi546Hd8aBnGZdFzpvIcYagJDDenPmXFc8d1p_Im4v7QqwSn3jDLOIiEsP1klCj9JDWioFp45GR4YMgX7Nkx84ERU8hqVRCoxPgcoaNmUAbvQ-N5KNNKITunqQH9GD6fgjgS2CikDj9qVc2tTZxU3ScRRCT9bG6XeqbGaJs7fzeYqp20Um7pSr0Zg43oc4-E6-A0_BERg',
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
  #filter(codigo %in% c('BRFXR0015','BRFXR0021','BRFXR0005'))
  filter(str_detect(grupo, 'Câmbio'))

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


