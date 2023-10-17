#' @title Exemplo de loop da função de update - Series
#' @author Luiz Paulo T.

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


# Metadados --------------------------------------------------------------------

metadados <- readxl::read_excel(paste0(user, path,
                                               'novos_indicadores.xlsx'))

metadados_filt <- metadados

# Unidade ----------------------------------------------------------------------

depara_unidade <- readxl::read_excel(paste0(user, path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

# Chamando a função GET FS-series ----------------------------------------------
# Função está no script modify_series 

sids_in_fs = get_sids(url = url_to_use,
                      token = token_to_use,
                      indicators = metadados_filt) %>%
  dplyr::rename(sids = code)

# Definindo a unidade de medida por SID

metadados_update <- sids_in_fs %>%
  #filter(str_detect(sids, 'ARINR0006')) %>% 
  dplyr::mutate(indicator_code = str_sub(sids, start = 1, end = 9),
                regioes = str_sub(sids, start = 10, end = 12),
                transfs = str_sub(sids, start = 13, end = 16)) %>%
  base::merge(metadados, by = "indicator_code") %>%
  select(indicator_code,
         regioes.x,
         transfs,
         original_pt,
         original_en,
         real_pt,
         real_en) %>%
  mutate(cod1_cod2 = paste0(str_sub(transfs, 1,1), str_sub(transfs, 4,4))) %>%
  left_join(depara_unidade %>%
            select(cod1_cod2, un_pt, un_en)) %>%
  rowwise() %>%
  mutate(un_pt = ifelse(is.na(un_pt),
                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_pt, real_pt),
                        un_pt),
         un_en = ifelse(is.na(un_en),
                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_en, real_en),
                        un_en),
         sid = paste0(indicator_code, regioes.x, transfs)) %>%
  dplyr::ungroup() %>% 
  rename(regioes = regioes.x)

# Loop -------------------------------------------------------------
# Aplicando update com a função modify_series

problem_sids <- tibble(sids = c())

for (i in 1:nrow(metadados_update)) {

  # Chamando a função modificação
  status <- modify_series(sid = metadados_update$sid[i],
                          units_en = metadados_update$un_en[i],
                          units_pt = metadados_update$un_pt[i],
                          token = token_to_use,
                          url = url_to_use)
  
  if(status != 200) {
    problem_sids <- problem_sids %>% 
      add_row(sids = metadados_update$sid[i])
  }

}


