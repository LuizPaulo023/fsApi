#' @title Envio de indicadores e update de indicadores na FS
#' @details A função aceita tanto o verbo PUT (para uodate) quanto POST (para envio)
#' @author Luiz Paulo Tavares Gonçalves

base::rm(list = ls())
graphics.off()

# Dependências =================================================================
# library(pacman)

pacman::p_load(tidyverse, httr, stringr, stringi)

# Configurações de ambiente do usuário 

user = base::getwd() %>%
       stringr::str_extract("^((?:[^/]*/){3})") %>% print()

path <- '4intelligence/Feature Store - Documentos/DRE/curadoria/'
setwd(paste0(user,path))

# Definindo parâmetros do usuário ----------------------------------------------------------
# getwd()
source("urls.R")

token_to_use = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImwudGF2YXJlc0A0aW50ZWxsaWdlbmNlLmNvbS5iciIsImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY5NzU0NzExOSwiZXhwIjoxNjk3NjMzNTE5LCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.FvbC3DRhMrKdFUpeqAdET75UCg0aaJJF3oZUcp4PiXpE48N-po5DYbdLBL_JP5RPNaVqVSebXXf7cPFlAQnqi7CdMLjbNWrYAMJ6k4iglkoFvESwkHYgewQNR9CiTF1WDBPAW_hj6YsT8s-rC1p3coeSEN6vJRfPh7HgGgI8QbRmKoQHMvo0Gi8P-RRGgOQMVHLPtgcE8cUQIa-kIACWg-6XXD5WeDD74ngUkCMy_GS-1iPuCY8pX88W7zuHUEpemgqrV2MHtIVHKoGeLztqJAs8nS-rids6EN3FwEw8GOqGyjgnaNFeKV8Wf8PzIKMlmi02OV4zNECg0CYxeKIvcA',
  'Content-Type' = 'application/json'
)

# Escolha o ambiente prod ou stg #\ opções: stg, prod

url_to_use = urls(environment = "stg")

# Carregar indicadores  ------------------------------------------------------------

novos_indicadores <- readxl::read_excel(paste0(user, path,
                                               'novos_indicadores.xlsx'))

metadados_filt <- novos_indicadores

# Loop indicadores -------------------------------------------------------------
  
problem_sids <- tibble(sids = c())

for (r in 1:nrow(metadados_filt)) {

  print(metadados_filt[r,'indicator_code'])
  
  # if(metadados_filt[r, 'in_fs']$in_fs) {
  #   proj = '4intelligence'
  # } else {
  #   proj = ' '
  # }

  # Chamando a função modificação
  status <- post.indicator(access_type = "default",
                           access_group = "Geral",
                           ranking = 1,
                           indicator = metadados_filt[r, 'indicator_code'][[1]],
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
                           country = str_sub(metadados_filt[r, 'indicator_code'],1,2)[[1]],
                           sector = str_sub(metadados_filt[r, 'indicator_code'],3,5)[[1]],
                           node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                                               ",")[[1]],
                           node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                                               ",")[[1]],
                           type_send = 'POST', #ou PUT
                           token = token_to_use,
                           proj_owner = ' ',
                           url = url_to_use)
  print(status)
}

