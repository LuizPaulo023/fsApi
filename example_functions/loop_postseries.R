library(tidyverse)
library(httr)

# Definindo parâmetros do usuário - dev  ----------------------------------------------------------

token_dev = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlpXYkhLcUtMeGxIVDdNX2lpbHVLVSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImcuYmVsbGVANGludGVsbGlnZW5jZS5jb20uYnIiLCJpc3MiOiJodHRwczovL2RldmVsb3BtZW50LTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDY0MDI0MDFiZTUxZjM0YWQ1OWFlNmVhNCIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vZGV2ZWxvcG1lbnQtNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjg2NjY1NzIyLCJleHAiOjE2ODY3NTIxMjIsImF6cCI6IlBseEk5NE9HbFRUNWZPaWJJYUFFdHFNOTFodDlUZXRUIiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.h0j3VZKgcYlP98YccyBN5iLJk7oG1RwkjFTJ5lwIYRffZDhDKGQ9ni4O40uL9ibYQC17PKyTm7AMBnU3qtXCMjh42mer24slYvXZITt2VI4vP8hPLpAhBTpDPc_WofLF3n4teq8rkW1TyH7Vz93FvwbJVimVvo2lpZs47nQc2AlFPpRmuWTBG5SjVgSvepe7bjXhV53rOVzUUduLxWW9PF8a0n_-2JlPUk54VxbJyNJ1HgEALkcm7fXZdAq3PQ27IghwPsb0nnJflKqbwVTj78PK8-SwVqTYg-AsKj1d06qiFGJb5dhxRZK-eFxwg2hA1_VU71Bm6sOHKuUogwEbUA',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo o Token do usuário - homologação ----------------------------------------------------------

token_hmg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlpXYkhLcUtMeGxIVDdNX2lpbHVLVSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImcuYmVsbGVANGludGVsbGlnZW5jZS5jb20uYnIiLCJpc3MiOiJodHRwczovL2RldmVsb3BtZW50LTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDY0MDI0MDFiZTUxZjM0YWQ1OWFlNmVhNCIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vZGV2ZWxvcG1lbnQtNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjg2NTY4NDc2LCJleHAiOjE2ODY2NTQ4NzYsImF6cCI6IlBseEk5NE9HbFRUNWZPaWJJYUFFdHFNOTFodDlUZXRUIiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.NJfqZ50whZX0ONRMcnyiX91ksBb8WZXBF1Nwv-nUpOwkXYuHM7RHL2H0WnIsJuCmtxQzT2jFDe_7zc4JvxiF72cBmuzlZcVkXQX0VcypnsE4C4Ze-1mWDJZa4NDo2V07epvVklbkaRQGjJJsFvhih_mCJS_z5s3c-Fd_aG7QaCyqkUtUCytS6zKbqPoYcvBCnoqOqLfEe9o0uKhETjl-K3P8xQUIOBH9s4lNltcFKnwoqHL_ADO6m5iWBifAuuC80TiCRXjy7g6M56emUCFQgIWnSf-QfySGL3n86pyqUE5zuVCjQKLUl0j-BCz5CUxAQmmTBBlJXsGRUk4h6P6StA',
  'Content-Type' = 'application/json'
)

url_hmg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'Bearer INSIRA O TOKEN DE ACESSO',
  'Content-Type' = 'application/json'
)

url_prod = 'https://run-prod-4casthub-featurestore-api-zdfk3g7cpq-ue.a.run.app/'


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

# Novas Aberturas ---------------------------------------------------------------------------------------

user <- 'C:/Users/GabrielBelle/'
path <- '4intelligence/Feature Store - Documentos/DRE/Documentação/migracao/'

grupo_transf <- readxl::read_excel(paste0(user, path,
                                          '/diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>%
  pivot_longer(cols = everything(), names_to = 'grupo', values_to = 'transfs') %>%
  arrange(grupo) %>%
  filter(!is.na(transfs))

depara_unidade <- readxl::read_excel(paste0(user, path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

sids_4macro <- readxl::read_excel(paste0(user, path,
                                         '/all_series_4macro.xlsx')) %>%
  mutate(series_code = str_sub(series_code, 1,13)) %>%
  distinct(series_code) %>%
  pluck('series_code')

metadados <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
                                skip = 1) %>% 
  janitor::clean_names()

regioes_depara <- tibble(
  max = 'NO1, NE1, SE1, SU1, CO1',
  ufx = 'RO2, AC2, AM2, RR2, PA2,
          AP2, TO2, MA2, PI2, CE2, RN2, PB2, PE2, AL2, SE2, BA2,
          MG2, ES2, RJ2, SP2, PR2, SC2, RS2, MS2, MT2, GO2, DF2')

metadados_filt <- metadados %>% 
  #Organiza as regioes pro script
  rename(regioes = regioes_4macro) %>% 
  mutate(regioes = str_replace_all(regioes, ' ', ','),
         regioes = str_replace_all(regioes, 'MAX', regioes_depara$max),
         regioes = str_replace_all(regioes, 'UFX', regioes_depara$ufx)) %>%
  #Organiza o grupo de transformação
  rename(grupo = grupo_transformacao) %>% 
  #Limpa os indicadores que não serão enviados
  filter(descontinuada == 'FALSE') %>% 
  filter(is.na(nao_migrar)) %>% 
  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
  filter(crawler == 'ceic')
         
#i = unique(metadados_filt[1,]$indicator_code)
#154 = EUGDP0099

for (i in unique(metadados_filt$indicator_code)) {
  df_filt <- metadados_filt %>%
    filter(indicator_code == i)

  #Gera todos os SIDs a partir do Subgrupo
  sids_by_group <- gen_sids_by_group(indicators_metadado = df_filt,
                                     depara_grupos = grupo_transf,
                                     depara_unidade = depara_unidade)

  #Mantem apenas os SIDs com a combinação de região+transf_primaria
  #Previamente existente no 4macro (e ativo)
  sids_sub13 <- str_sub(sids_by_group$sid, 1, 13)
  sids_to_send <- sids_by_group$sid[sids_sub13 %in% sids_4macro]

  sids_to_send_metadata <- sids_by_group %>% 
    #filter(str_sub(sid, 13,13) == 'O')
    filter(sid %in% sids_to_send)
  
  print(paste0("Enviando as aberturas para o indicador: ", i))
  
  if(sids_to_send_metadata %>% nrow() != 0){
    
    post_series(indicators_metadado = sids_to_send_metadata,
                token = token_to_use,
                url = url_to_use)
  } else {
    F
  }

  del_sids <- select_sids_to_del(indicator = i,
                                 new_sids = sids_to_send_metadata,
                                 token = token_to_use,
                                 url = url_to_use)

  if(!identical(del_sids, character(0))) {
    print(paste0("Deletando aberturas indesejadas do indicador: ", i))
    delete_series(indicator = i,
                  del_series = del_sids,
                  token = token_to_use,
                  url = url_to_use)
  } else {
    print(paste0("Sem aberturas para excluir para o indicador ", i))
  }
  
  Sys.sleep(0.5)
}


