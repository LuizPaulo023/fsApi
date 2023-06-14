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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJpc3MiOiJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2Mjk4ZjllMzhhZTVjZTAwNjkwNzA2MDIiLCJhdWQiOlsiNGNhc3RodWIiLCJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODY3NDUxMDksImV4cCI6MTY4NjgzMTUwOSwiYXpwIjoiS1FtZXZ1d0lRbzVZd0tGb29HQ1VyVWZzRVVpOHlLMzQiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.RQZyauSCTdIJlet8Bcvi_PaAwd16wBFslm077iIOUydWmb4KHD1XEff8sbI_8nxzbijeoIO7Zq4_5f4mLivPyR2fz9u23s4dhIA-7MRrpG8nqwcpH8QUBndWZXD88FAhW7_DATQ-BJq5BkL_Z3T5OSzqwewDWpfT6i-mwrMrQI6T9f4WrN3lCtoouHVyXgDAW28ZhRyubIl1ubLiAvt9ad5cWcGj66FGx_Bu9zcI2dHq3dqvLL2hIsRTatGfBltM9i-K1dcBkeXpsipr5AsWjEpsMuOkliLxL6DiFyVmaGaaXh7Cu5LiqS0gnrE9FEL-MsSqVj0OjQtFjg8cRviEnA',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'XXXXXXXXXXXXXXXXXXX',
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
                  mutate(across(starts_with('description') | contains('_fs'),
                                ~ifelse(is.na(.x), "...", .x)),
                         name_abv_pt_fs = iconv(name_abv_pt_fs,
                                                from="UTF-8",to="ASCII//TRANSLIT")
                  ) %>%
                  mutate(across(starts_with('description'), ~str_replace_all(.x, '"',"'"))) %>%
                  filter(in_fs == T) %>% #\ Presentes na FS
                  filter(descontinuada == 'FALSE') %>%
                  filter(is.na(nao_migrar)) %>%
                  filter(str_detect(grupo_4macro, c('Geral'))) 
                  #filter(crawler == 'yahoo_finance')
                  #filter(!is.na(link_metodologia_fs)) %>%
                  #filter(link_metodologia_fs != "...")

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
    access_type = "default",
    indicator = metadados_filt[r, 'indicator_code'][[1]],
    name_en = metadados_filt[r, 'name_en_fs'][[1]],
    name_pt = metadados_filt[r, 'name_pt_fs'][[1]],
    short_en = metadados_filt[r, 'name_abv_en_fs'][[1]],
    short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]],
    source_en = metadados_filt[r, 'fonte_fs'][[1]],
    source_pt = metadados_filt[r, 'fonte_fs'][[1]],
    description_en =  fix_description_en,
    description_pt =  fix_description_pt,
    description_full_en = metadados_filt[r, 'link_metodologia_fs'][[1]],
    description_full_pt = metadados_filt[r, 'link_metodologia_fs'][[1]],
    node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                        ",")[[1]][[1]],
    node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                        ",")[[1]][[1]],
    token = token_to_use,
    url = url_to_use)
  
  if(status != 200) {
    problem_sids <- problem_sids %>% 
      add_row(sids = metadados_filt[r, 'indicator_code'][[1]])
  }
  
}

