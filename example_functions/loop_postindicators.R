#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

rm(list = ls())

library(tidyverse)
library(stringi)
library(httr)


# Definindo parâmetros do usuário - dev  ----------------------------------------------------------
token_dev = c(
  'Authorization' = 'Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente Stg

token_stg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL25hbWUiOiJnLmJlbGxlQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaXNzIjoiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjI5OGY5ZTM4YWU1Y2UwMDY5MDcwNjAyIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjk3NDY0NjMyLCJleHAiOjE2OTc1NTEwMzIsImF6cCI6IktRbWV2dXdJUW81WXdLRm9vR0NVclVmc0VVaTh5SzM0Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImFzazpxdWVzdGlvbnMiLCJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.xYIX4E3atIDYzKASAwgHWl5aiwdbJH2KqJk84DW4Y2MEKiHRkPss1E48yZAODFtk3LozJjWqHDITuwzTpa-63nNuOSBm_33HrToo5FCFkQMbUO2j7SM9km5tEI6tUsxABhUnjdnepWH0agsIU0MvggNyahNuxWKq5EQZt103-eghlgorXqG9T9ec19_CI_1jxlPpAf7OZFU5fct-sAiNAQpq5hJkFBDag1lQSz0KiCdP3vzXPK7ionQlhUXqDWBAwsCHmN0wqH3HYv2OutwJzp8ciry4AA1Vflo_KhJjRCvdKS7QMoGSD_l_nk1p4IY4T3-cpP29Xdh51_yy9WmLoQ',
  'Content-Type' = 'application/json'
)

url_stg = "https://apis.4intelligence.ai/api-feature-store-stg/"

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNFZGl0b3IiLCJpczRpIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJiZG1nIl19LCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYyMzRjNDI0YTE4ZjM3MDA2OGI3MTFkOSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjg4MDQwMjE3LCJleHAiOjE2OTA2MzIyMTcsImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.J6pJE3lqyTCiwd_deyYoIMvwTTfyFNLVfqTHHWnfQ7hbliiCuK4Y5Y3aG9uV_WKA0cdbTY5G6yGygJBYdGqXDpWlEOlQmglsLiP_Y5Y6Z_bl5m2p3CFDPm6PBOPuJVSZu5IF4teDHKwxHlcaRji-gALnNRosDADfrsnC_YlMTC5Q00_bmauP-CRYXppAvbxAw6PKb6C9-hsswh7EPhLl934FBRcVHFqCIFpzkAh9WHquvpmR5ke2JZccnTY9X9jMFAIHmeM5XKQeLExwxAPwrmQSr7AFTD94vkM03kQcE8hxPpe_Uu7unTjHffV_JCE6m1tPZHqJ0N3McI8Lsp5-bg',
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

# Carrega metadados -------------------------------------------------------

user = base::getwd() %>%
       stringr::str_extract("^((?:[^/]*/){3})") %>% print()

path <- '4intelligence/Feature Store - Documentos/DRE/curadoria/'

metadados <- readxl::read_excel(paste0(user, path, 'novos_indicadores.xlsx')) %>%
  janitor::clean_names()

metadados_filt <- metadados %>%
  mutate(name_abv_pt_fs = iconv(name_abv_pt_fs,
                                   from="UTF-8",to="ASCII//TRANSLIT"),
         across(where(is.character), ~gsub('\r','', .x)),
         across(where(is.character), ~gsub('\n','', .x)),
         across(starts_with('description'), ~str_replace_all(.x, '"',"'"))
         ) %>%
  #Renomeia valores NA
  mutate(ranking = ifelse(is.na(ranking), 1, ranking),
         indicator_code = ifelse(is.na(indicator_code), "", indicator_code),
         premium = ifelse(is.na(premium), "default", "premium"),
         group_access = ifelse(is.na(premium), "Geral", " "),
         projecao = ifelse(is.na(projecao), ' ', projecao)
  )

type_to_send = 'POST' #PUT

# Loop de envio de indicadores ------------------------------------------------------------------------------
status_out <- tibble(output = character())

for (r in 1:nrow(metadados_filt)) {

  print(metadados_filt[r,'indicator_code']$indicator_code)
  print(paste("Método de envio é", type_to_send))

  if (ambiente == 'stg') {
    node_en_send <- str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                              ", ")[[1]]
    node_pt_send <- str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                              ", ")[[1]]
  } else if (ambiente == 'prod') {
    node_en_send <- str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                              ", ")[[1]][1]
    node_pt_send <- str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                              ", ")[[1]][1]
  }

  send_indicadores = post.indicator(access_type = metadados_filt[r, 'premium'][[1]],
                                    access_group = metadados_filt[r, 'group_access'][[1]],
                                    indicator = metadados_filt[r, 'indicator_code'][[1]],
                                    ranking = metadados_filt[r, 'ranking'][[1]],
                                    name_en = metadados_filt[r, 'name_en_fs'][[1]],
                                    name_pt = metadados_filt[r, 'name_pt_fs'][[1]],
                                    short_en = metadados_filt[r, 'name_abv_en_fs'][[1]],
                                    short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]],
                                    source_en = metadados_filt[r, 'fonte_fs_en'][[1]],
                                    source_pt = metadados_filt[r, 'fonte_fs_pt'][[1]],
                                    description_en = metadados_filt[r, 'description_en_fs'][[1]],
                                    description_pt = metadados_filt[r, 'description_pt_fs'][[1]],
                                    description_full_en = metadados_filt[r, 'link_metodologia_fs_en'][[1]],
                                    description_full_pt = metadados_filt[r, 'link_metodologia_fs_pt'][[1]],
                                    country = metadados_filt[r, 'pais'][[1]],
                                    sector = metadados_filt[r, 'setor_fs'][[1]],
                                    node_en = node_en_send,
                                    node_pt = node_pt_send,
                                    proj_owner = metadados_filt[r, 'projecao'][[1]],
                                    type_send = type_to_send,
                                    token = token_to_use,
                                    url = url_to_use)

  status_out <- status_out %>%
    bind_rows(tibble(output = send_indicadores))

  print(send_indicadores)
}

# access_type = metadados_filt[r, 'premium'][[1]]
# access_group = metadados_filt[r, 'group_access'][[1]]
# indicator = metadados_filt[r, 'indicator_code'][[1]]
# ranking = metadados_filt[r, 'ranking'][[1]]
# name_en = metadados_filt[r, 'name_en_fs'][[1]]
# name_pt = metadados_filt[r, 'name_pt_fs'][[1]]
# short_en = metadados_filt[r, 'name_abv_en_fs'][[1]]
# short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]]
# source_en = metadados_filt[r, 'fonte_fs_en'][[1]]
# source_pt = metadados_filt[r, 'fonte_fs_pt'][[1]]
# description_en = metadados_filt[r, 'description_en_fs'][[1]]
# description_pt = metadados_filt[r, 'description_pt_fs'][[1]]
# description_full_en = metadados_filt[r, 'link_metodologia_fs_en'][[1]]
# description_full_pt = metadados_filt[r, 'link_metodologia_fs_pt'][[1]]
# country = metadados_filt[r, 'pais'][[1]]
# sector = metadados_filt[r, 'setor_fs'][[1]]
# node_en = node_en_send
# node_pt = node_pt_send
# proj_owner = metadados_filt[r, 'projecao'][[1]]
# type_send = type_to_send
# token = token_to_use
# url = url_to_use

