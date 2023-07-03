#' @title Exemplo de loop da função de update indicador
#' @author Luiz Paulo Tavares Gonçalves

rm(list = ls())

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
  'Authorization' = '',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente Stg

token_stg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY4NzUyMjQ3MywiZXhwIjoxNjg3NjA4ODczLCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.MJoZDoa9PpKXfq1TQKr09SFEbKeuV7AjTeeJ-ypOcRgMgh-LqsDRjIIhtv8KcHbv_ba2ognTrEnGYYtm02UhbTmdfU1wVr6EzMHLF4Hm0veZ1CMzi6S5cnOU_u8kOlEqRWiSM_YhF4_vfu0zc-sM8wVSZNpHt41x3J3RBL8uirG77b6Jh4Ac2GMEHbrrcIcPLAt5e8naILmbgIbl3czOTokJFU26nLKA0eBL_iPpRB1S_qvyQY4ZlkTPB3Ryb-1QzO8NX2H9pOjMxOhBvia-PyUzBNczG-1R3mWajOeO3EEtXpQ-ImTdaAMlthJRHCBpiJ8o7k66DfRUQS00IVnDaQ',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNFZGl0b3IiLCJpczRpIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJiZG1nIl19LCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYyMzRjNDI0YTE4ZjM3MDA2OGI3MTFkOSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjg3OTUzODc5LCJleHAiOjE2OTA1NDU4NzksImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.AyTmqLBD-B0HOpCg4XckOrOXvYJJR55SFAYGclcEyyjcsnrj0s5g_MDGF_QTt0mnPKd_sOlUzGW_uXb8ZsUwdDauGRz_Kq5yhA48vwXRUXThAhtit7FZFZaOw4IHjCLnmCci__VZ552LDbE7Rwf2pfBU5_LSIa_MUkLY64tg6_q3A-B1Kzzns4wKNJxTGMzdjcEKSvB2GsJv5iHzs7fkSMfrrdNVx48q5hSeP95Oua-WyUU6iUg2ogaK9GoChgRuOOt0nxfbKMiWXF3ZCbPDsbIpjSu9imkDsP8kW4Rdo2Jg9sM3ndsmNsOmGSifiSVA5Z1xYavDsd4bSHjMUtnRvg',
  'Content-Type' = 'application/json'
)

url_prod = 'https://run-prod-4casthub-featurestore-api-zdfk3g7cpq-ue.a.run.app/'

# Definindo o ambiente ---------------------------------------------------------

ambiente = 'prod' #\ opções: dev, stg, prod

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

# Carrega metadados ------------------------------------------------------------
# Importando dataset com os dados para teste

metadados <- readxl::read_excel(paste0(user,
                                       path,
                                       'metadados_migração.xlsx'),
                                skip = 1) %>%
             janitor::clean_names()


# Limpando e organizando metadados ---------------------------------------------
# Exemplo retirado do script: loop_postindicators
# Filtros adicionais no final do bloco a seguir
# Filtrando apenas as linhas com link_metodologia, sem NA ou ...

metadados_filt <- metadados %>%
                  mutate(
                    # across(starts_with('description') | contains('_fs'),
                    #              ~ifelse(is.na(.x), "...", .x)),
                         name_abv_pt_fs = iconv(name_abv_pt_fs,
                                                from="UTF-8",to="ASCII//TRANSLIT")
                  ) %>%
                  mutate(across(starts_with('description'), ~str_replace_all(.x, '"',"'"))) %>%
                  #filter(in_fs == F) %>% #\ Presentes na FS
                  filter(descontinuada == 'FALSE') %>%
                  filter(is.na(nao_migrar)) %>%
                  filter(str_detect(grupo_4macro, c('Geral'))) %>%  
                  filter(crawler %in% c("abecip", 
                                        "secovi")) 
                  #filter(description_en_fs != is.na(description_en_fs)) 
                  #filter(indicator_code %in% c("ARGDP0110", 
                  #                             "ARGDP0047"))
                  #filter(!is.na(link_metodologia_fs)) %>%
                  #filter(link_metodologia_fs != "...")

metadados_filt

# Loop indicadores -------------------------------------------------------------
  
problem_sids <- tibble(sids = c())

for (r in 1:nrow(metadados_filt)) {

  print(metadados_filt[r,'indicator_code'])

  fix_description_pt = gsub("\n", "", metadados_filt[r, 'description_pt_fs'][[1]])
  fix_description_en = gsub("\n", "", metadados_filt[r, 'description_en_fs'][[1]])
  fix_description_pt = gsub("\r", "", fix_description_pt)
  fix_description_en = gsub("\r", "", fix_description_en)

  # Chamando a função modificação
  status <- modify_indicator(
    modify_ind = TRUE,
    access_type = "default",
    indicator = metadados_filt[r, 'indicator_code'][[1]],
    name_en = metadados_filt[r, 'name_en_fs'][[1]],
    name_pt = metadados_filt[r, 'name_pt_fs'][[1]],
    short_en = metadados_filt[r, 'name_abv_en_fs'][[1]],
    short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]],
    source_en = metadados_filt[r, 'fonte_fs_en'][[1]],
    source_pt = metadados_filt[r, 'fonte_fs_pt'][[1]],
    description_en =  fix_description_en,
    description_pt =  fix_description_pt,
    description_full_en = metadados_filt[r, 'link_metodologia_fs_en'][[1]],
    description_full_pt = metadados_filt[r, 'link_metodologia_fs_pt'][[1]],
    node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                        ",")[[1]],
    node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                        ",")[[1]],
    token = token_to_use,
    url = url_to_use)
  
  # if(any(status != 200)) {
  #   problem_sids <- problem_sids %>% 
  #     add_row(sids = metadados_filt[r, 'indicator_code'][[1]])
  # }
  
}


########################################################


access_type = "default"
indicator = metadados_filt[r, 'indicator_code'][[1]]
name_en = metadados_filt[r, 'name_en_fs'][[1]]
name_pt = metadados_filt[r, 'name_pt_fs'][[1]]
short_en = metadados_filt[r, 'name_abv_en_fs'][[1]]
short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]]
source_en = metadados_filt[r, 'fonte_fs_en'][[1]]
source_pt = metadados_filt[r, 'fonte_fs_pt'][[1]]
description_en =  fix_description_en
description_pt =  fix_description_pt
description_full_en = metadados_filt[r, 'link_metodologia_fs_en'][[1]]
description_full_pt = metadados_filt[r, 'link_metodologia_fs_pt'][[1]]
node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                    ",")[[1]]
node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                    ",")[[1]]
token = token_to_use
url = url_to_use
