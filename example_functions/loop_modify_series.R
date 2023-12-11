#' @title Exemplo de loop da função de update - Series
#' @author Luiz Paulo T.

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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJmYWFzLWludGVybm8iLCJncGEiLCJ2aWF2YXJlam8iLCJhbmJpbWEiXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImcuYmVsbGVANGludGVsbGlnZW5jZS5jb20uYnIiLCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDY0MDBkNTdlODU1Yzg0YzE5MTRhNzc0ZCIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjk4ODUwODI0LCJleHAiOjE3MDE0NDI4MjQsImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImFzazpxdWVzdGlvbnMiLCJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.jEeUHFdI3VBirTPSjhxIH59ddQbooS6P-aXetbRMnsi2BlnQemJgbNO3IxwbriXF5kflqXTpMPe851I4uFzGUAQEjgqyiuBn-cdY5bfsYcrqhuBn6YAb8X3P2ziinZ9xC0mgbIfxurjWnJgSLIEZKzPq1pgXdDdjHAdBHDWT-C__C1GwzxB3OIFSJrsVNCrsB_q39p6nUo1cXhLCSIvJphO8jT77srn-1NNqAy2nJjYYNsRn86UklNAZ3YPRpOqFQROZTwIOUOUWZX652kZynpNsUl_kzU99ZBl4l8TA3BU8aifpNRRth_uS03uHHhTNNyFqLyWcFxSA1ILAFYCJOA',
  'Content-Type' = 'application/json'
)

# Escolha o ambiente prod ou stg #\ opções: stg, prod

url_to_use = 'https://apis.4intelligence.ai/api-feature-store/'
#urls(environment = "prod")


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
                      indicators = metadados_filt$indicator_code) %>%
  dplyr::rename(sids = code)

  # Definindo a unidade de medida por SID

metadados_update <- sids_in_fs %>%
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


# Anbima ------------------------------------------------------------------

metadados_anbima <- readxl::read_excel(paste0(user, path,
                                              'indicadores_unidade_USD.xlsx'))

metadados_filt <- metadados_anbima %>%
  pluck('Indicador')

sids_in_fs = get_sids(url = url_to_use,
                      token = token_to_use,
                      indicators = metadados_filt) %>%
  dplyr::rename(sids = code)

metadados_update <- sids_in_fs %>%
  mutate(
    un_pt = case_when(
      str_sub(sids, 10, 12) == 'NMC' & str_sub(sids, 7,7) == 'L' ~ 'Pessoas',
      str_sub(sids, 16,16) %in% c('L', 'C', 'I') ~ 'USD',
      str_sub(sids, 16,16) != 'L' ~ '%'),
    un_en = case_when(
      str_sub(sids, 10, 12) == 'NMC' & str_sub(sids, 7,7) == 'L' ~ 'People',
      str_sub(sids, 16,16) %in% c('L', 'C', 'I') ~ 'USD',
      str_sub(sids, 16,16) != 'L' ~ '%')
  ) %>%
  filter(un_pt == 'USD')

# Loop -------------------------------------------------------------
# Aplicando update com a função modify_series

problem_sids <- tibble(sids = c())

for (i in 1:nrow(metadados_update)) {

  # Chamando a função modificação
  status <- modify_series(sid = metadados_update$sid[i],
                          tipo_acesso = 'default',
                          units_en = metadados_update$un_en[i],
                          units_pt = metadados_update$un_pt[i],
                          token = token_to_use,
                          url = url_to_use)

  if(status != 200) {
    problem_sids <- problem_sids %>%
      add_row(sids = metadados_update$sid[i])
  }

}


