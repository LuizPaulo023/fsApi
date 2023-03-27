# install.packages("devtools")
# devtools::install_github("LuizPaulo023/fsApi", ref = "main")

#library(fsApi)

library(tidyverse)
library(httr)

# Definindo o Token do usuário - homologação ----------------------------------------------------------

token_hmg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJpc3MiOiJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2Mjk4ZjllMzhhZTVjZTAwNjkwNzA2MDIiLCJhdWQiOlsiNGNhc3RodWIiLCJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2Nzk2NjI5MDIsImV4cCI6MTY3OTc0OTMwMiwiYXpwIjoiS1FtZXZ1d0lRbzVZd0tGb29HQ1VyVWZzRVVpOHlLMzQiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.qqP6hTKij2SQCNO4cy5XB1InHNw98IQT8UT17ETIAikDKVD85BUdEtgPXDadOkghE7cipoC8TvD-XxsVSDaHJtvbDtZjpUZf2DMX8L8iSKrC2PyJsLI0p3iau5QaeY3JobBdwE_V5IXwaW6ikpLwkZLD9OKMxdqp_7InLQ1FqHo5dhta4prP6XeJWjqTsNDv2y040cJbL6ZXVvbhhDK-Wpa5islezLZHSt7ABCnSTIAcivONI9MZ-Zani95k_vaRev08qTWjJvy7YwqnNm_KUZHnb-2SH0yAdZj9Xw5b2dyid0H0fal899kF_YOwj-fPc1BKoZddnZdRw176TdZFgg',
  'Content-Type' = 'application/json'
)

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'Bearer INSIRA O TOKEN DE ACESSO',
  'Content-Type' = 'application/json'
)

# Novas Aberturas ---------------------------------------------------------------------------------------

belle_path <- 'C:/Users/GabrielBelle/4intelligence/Feature Store - Documentos/DRE/Documentação/migracao'

indicators_metadado <- readxl::read_excel(paste0(belle_path,
                                            '/grupos_transfs_FS.xlsx')) %>%
  select(codigo, grupo, subgrupo, rg, starts_with('original_'), starts_with('real_')) %>%
  mutate(grupo = paste0(grupo, ' - ', subgrupo)) %>% 
  rename(regioes = rg) %>% 
  filter(startsWith(grupo, 'Taxa') |
           startsWith(grupo, 'Volume - FN')) %>% 
  #filter(startsWith(codigo, 'BRMTG')) %>% 
  filter(grupo != 'NA - NA')
  

grupo_transf <- readxl::read_excel(paste0(belle_path,
                                          '/diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>%
  pivot_longer(cols = everything(), names_to = 'grupo', values_to = 'transfs') %>%
  arrange(grupo) %>%
  filter(!is.na(transfs))

depara_unidade <- readxl::read_excel(paste0(belle_path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

sids_4macro <- readxl::read_excel(paste0(belle_path, 
                                         '/all_series_4macro.xlsx')) %>% 
  mutate(series_code = str_sub(series_code, 1,13)) %>% 
  distinct(series_code) %>% 
  pluck('series_code')

#Problemas:
# Excluir apenas o SID errado, evitando desabilitar indicador
# Subir apenas transf primaria que ja existe no 4macro, de acordo com a região

#i = unique(indicators_metadado[69,]$codigo)

for (i in unique(indicators_metadado$codigo)) {
  df_filt <- indicators_metadado %>%
    filter(codigo == i)
  
  #Gera todos os SIDs a partir do Subgrupo
  sids_by_group <- gen_sids_by_group(indicators_metadado = df_filt,
                                     depara_grupos = grupo_transf,
                                     depara_unidade = depara_unidade)
  
  #Mantem apenas os SIDs com a combinação de região+transf_primaria
  #Previamente existente no 4macro (e ativo)
  sids_sub13 <- str_sub(sids_by_group$sid, 1, 13)
  sids_to_send <- sids_by_group$sid[sids_sub13 %in% sids_4macro]
  
  sids_to_send_metadata <- sids_by_group %>% 
    filter(sid %in% sids_to_send)
  
  print(paste0("Enviando as aberturas para o indicador: ", i))
  
  #post_series(indicators_metadado = sids_to_send_metadata, token = token_hmg)
  
  del_sids <- select_sids_to_del(indicator = i,
                                 new_sids = sids_to_send,
                                 token = token_hmg)
  
  if(!identical(del_sids, character(0))) {
    print(paste0("Deletando aberturas indesejadas do indicador: ", i))
    delete_series(indicator = i,
                  del_series = del_sids, 
                  token = token_hmg)
  } else {
    print(paste0("Sem aberturas para excluir para o indicador ", i))
  }
  Sys.sleep(0.5)
}


