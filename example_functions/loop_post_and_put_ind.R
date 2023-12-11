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
  'Authorization' = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL25hbWUiOiJnLmJlbGxlQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaXNzIjoiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjI5OGY5ZTM4YWU1Y2UwMDY5MDcwNjAyIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNzAwNzQyNjU4LCJleHAiOjE3MDA4MjkwNTgsImF6cCI6IktRbWV2dXdJUW81WXdLRm9vR0NVclVmc0VVaTh5SzM0Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImFzazpxdWVzdGlvbnMiLCJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.NWNyKFqPLtvBgD1sLkpPmfj9BDOcTH53sPLE6h8cLvvSZdvfPTcBWKRMYtinKBijKqBb3EfaMprEsEAmDWqtBLTCQ7U4oKoyrYK_Ae0eSk79_T8jeiYYRk-zC37aR7lxgFQpLGFFOvBu7XWRDCaZ0Mmq-Fm0SZuYkYpudFmgccZFWQHNnZl7e3Oa-qHIwosSoJdi7MbLrckJtgQ1YFeaYsXot0xNsMb-VnO8D9HdFgS8HewkPGAfk_wSaU8vJuW3RA9DsYOQlaTnBeKLfkNoo4vMs0EukrqbofPii2qkOJajJnb47Y2Ox7KM397Iyq4QrTW0YO-_6ue4YevJBDBWTw',
  'Content-Type' = 'application/json'
)

# Escolha o ambiente prod ou stg #\ opções: stg, prod

url_to_use = urls(environment = "stg")

# Carregar indicadores  ------------------------------------------------------------

novos_indicadores <- readxl::read_excel(paste0(user, path,
                                               'novos_indicadores.xlsx'))

# Anbima
novos_indicadores <- readxl::read_excel(paste0(user, path,
                                               'anbima/novos_indicadores.xlsx'))
#Não criar fundos <33 dias de existencia

metadados_filt <- novos_indicadores %>%
  mutate(name_abv_pt_fs = iconv(name_abv_pt_fs,
                                from="UTF-8",to="ASCII//TRANSLIT"),
         across(where(is.character), ~gsub('\t','', .x)),
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

# Loop indicadores -------------------------------------------------------------

status_out <- tibble(row_id = c(), output = character())

for (r in 1:nrow(metadados_filt)) {

  print(metadados_filt[r,'indicator_code'])
  print(paste("Método de envio é", type_to_send))

  # Chamando a função modificação
  status <- post.indicator(access_type = metadados_filt[r, 'premium'][[1]],
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
                           node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                                               ",")[[1]],
                           node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                                               ",")[[1]],
                           proj_owner = metadados_filt[r, 'projecao'][[1]],
                           type_send = type_to_send,
                           url = url_to_use,
                           token = token_to_use)

  status_out <- status_out %>%
    bind_rows(tibble(row_id = r, output = status))

  print(status)
}

access_type = metadados_filt[r, 'premium'][[1]]
access_group = metadados_filt[r, 'group_access'][[1]]
indicator = metadados_filt[r, 'indicator_code'][[1]]
ranking = metadados_filt[r, 'ranking'][[1]]
name_en = metadados_filt[r, 'name_en_fs'][[1]]
name_pt = metadados_filt[r, 'name_pt_fs'][[1]]
short_en = metadados_filt[r, 'name_abv_en_fs'][[1]]
short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]]
source_en = metadados_filt[r, 'fonte_fs_en'][[1]]
source_pt = metadados_filt[r, 'fonte_fs_pt'][[1]]
description_en = metadados_filt[r, 'description_en_fs'][[1]]
description_pt = metadados_filt[r, 'description_pt_fs'][[1]]
description_full_en = metadados_filt[r, 'link_metodologia_fs_en'][[1]]
description_full_pt = metadados_filt[r, 'link_metodologia_fs_pt'][[1]]
country = metadados_filt[r, 'pais'][[1]]
sector = metadados_filt[r, 'setor_fs'][[1]]
node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                    ",")[[1]]
node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                    ",")[[1]]
proj_owner = metadados_filt[r, 'projecao'][[1]]
type_send = type_to_send
url = url_to_use
token = token_to_use
