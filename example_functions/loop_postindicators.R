#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

library(tidyverse)
library(httr)


# Definindo parâmetros do usuário - dev  ----------------------------------------------------------

token_dev = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlpXYkhLcUtMeGxIVDdNX2lpbHVLVSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImcuYmVsbGVANGludGVsbGlnZW5jZS5jb20uYnIiLCJpc3MiOiJodHRwczovL2RldmVsb3BtZW50LTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDY0MDI0MDFiZTUxZjM0YWQ1OWFlNmVhNCIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vZGV2ZWxvcG1lbnQtNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjgwNTI5MzYzLCJleHAiOjE2ODA2MTU3NjMsImF6cCI6IlBseEk5NE9HbFRUNWZPaWJJYUFFdHFNOTFodDlUZXRUIiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.rvII03XOg7SZaUc0aFg1qISZK8I0ME1TbXbQDTgPKAtjkp1BHRKGHl9N5I5Vz8Um8u0uPfJSTJiQwzlxUt5IRFKP3RQNie-rH-XTMN0Uyr-OpH0RMfYQmKxKGrdO2etSnY7CCZg57eSEIPVyM2_DH5r-dAbIxvDtmcvWP9S2c57Mk6drH3gUP0DX-k2CfCoEzuDHty7tvizGt0XdwPOyZ6K4GpkNs2jXPkKhD52NhD7cd1ShkXU2F8TZJEedCx8u4ECyCIaWbDOxgjW7C26ivJAtHyFX5envAMDbcTaocgA52z9dPN4jNuN9mdwjh5oPQ0_36uLSC0-FTxa1-bYvfg',
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


# Carrega metadados -------------------------------------------------------

user <- 'C:/Users/GabrielBelle/'
path <- '4intelligence/Feature Store - Documentos/DRE/Documentação/migracao/'

metadados <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
                                skip = 1) %>% 
  janitor::clean_names()

metadados_filt <- metadados %>% 
  filter(in_fs == F) %>% 
  filter(descontinuada == 'FALSE') %>% 
  filter(is.na(nao_migrar)) %>% 
  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
  filter(crawler == 'indec')


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
                                    token = token_dev,
                                    url = url_dev)
  
}

send_indicadores = post.indicator(access_type = "default",
                                  access_group = "Geral",
                                  indicator_code = "ARBOP0067",
                                  name_en = "ARG - Exports of Goods",
                                  name_pt = "ARG - Exportações de Bens A",
                                  short_en = "Export. Goods",
                                  short_pt = "Exp. Bens",
                                  source_en = "Indec",
                                  source_pt = "Indec",
                                  description_en = "....",
                                  description_pt = "...",
                                  description_full_en = "...",
                                  description_full_pt = "...",
                                  country = "AR",
                                  sector = "BOP",
                                  node_en = "Argentina",
                                  node_pt = "Argentina",
                                  token = token_dev,
                                  url = url_dev)

