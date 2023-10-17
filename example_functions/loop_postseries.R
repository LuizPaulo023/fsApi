#' @title Envio de séries/aberturas FS

base::rm(list = ls())
graphics.off()

# Dependências =================================================================
# library(pacman)

pacman::p_load(tidyverse, httr)

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

# Novas Aberturas ---------------------------------------------------------------------------------------

grupo_transf <- readxl::read_excel(paste0(user, path,
                                          'diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>%
  pivot_longer(cols = everything(), names_to = 'grupo', values_to = 'transfs') %>%
  arrange(grupo) %>%
  filter(!is.na(transfs))

depara_unidade <- readxl::read_excel(paste0(user, path,
                                            'diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

regioes_depara <- tibble(
  max = 'NO1, NE1, SE1, SU1, CO1',
  ufx = 'RO2, AC2, AM2, RR2, PA2, AP2, TO2, MA2, PI2, CE2, RN2, PB2, PE2, AL2, SE2, BA2, MG2, ES2, RJ2, SP2, PR2, SC2, RS2, MS2, MT2, GO2, DF2')

novos_indicadores <- readxl::read_excel(paste0(user, path,
                                               'novos_indicadores.xlsx'))

metadados_filt <- novos_indicadores %>%
  mutate(regioes = str_replace_all(regioes, " ", ", "))


# Loop de envio -----------------------------------------------------------

problems = tibble(sid = c(), status = c())
sids_to_del <- tibble(ind = c(), sids = c())

for (i in unique(metadados_filt$indicator_code)) {

  df_filt <- metadados_filt %>%
    filter(indicator_code == i)

  #Gera todos os SIDs a partir do Subgrupo
  sids_by_group <- gen_sids_by_group(indicators_metadado = df_filt,
                                     depara_grupos = grupo_transf,
                                     depara_unidade = depara_unidade)

  #Filtros específicos em cima do grupo de transf. gerado

  sids_to_send_metadata <- sids_by_group %>%
    filter(str_sub(sid, 13, 13) != 'S') %>%
    filter(str_sub(sid, 13, 13) != 'R')

  print(paste0("Enviando as aberturas para o indicador: ", i))

  if(sids_to_send_metadata %>% nrow() != 0){

   post_sid =  post_series(indicators_metadado = sids_to_send_metadata,
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
}


