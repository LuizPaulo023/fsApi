#' @title Envio de séries/aberturas FS
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
  'Authorization' = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJmYWFzLWludGVybm8iLCJncGEiLCJ2aWF2YXJlam8iLCJhbmJpbWEiXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImcuYmVsbGVANGludGVsbGlnZW5jZS5jb20uYnIiLCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDY0MDBkNTdlODU1Yzg0YzE5MTRhNzc0ZCIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNzAzMTYxMTcxLCJleHAiOjE3MDU3NTMxNzEsImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImFzazpxdWVzdGlvbnMiLCJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.XxXdg0n4UGrrdKo0yhXDI9LMNRrCps9Xp8nKpUjjwtYi7b03r3d1jAayWDXGHNdziv-mnsu3qffB657fvZTGnQZo-EAYaOfl8qbXEIdB-hbIkz6tT8bJVpY_xyPZXMamCT_ows9eQMNSCjJL_0IVsx9HSV6DOGASZsV_q2IBuLKYOOiODw0057SFEr4ETkFjIeZxFgx_fNgT8bYwSB4JPAhPfcVNw1FFdhjJ0yta3u2K0ReOY90PM6dAsPh4dZklWYRkDDKzS_KMXzWYdElNLsWEBxbMWVbzqFMfdw4eRPczhGobpvL0lOCcSjL18vvAxTHaMORfq555TiZRcP8bJw',
  'Content-Type' = 'application/json'
)

# Escolha o ambiente prod ou stg #\ opções: stg, prod

url_to_use = urls(environment = "prod")

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


# Criar SIDs inexistentes - Buracos ---------------------------------------

ind_buraco <- readxl::read_excel(paste0(user, path,
                                          'indicador_grupo_transfs.xlsx'))

grupos_disp <- ind_buraco[['grupo_transformação']] %>%
  unique()

metadados_filt <- ind_buraco %>%
  filter(`grupo_transformação` %in% grupos_disp[[1]])

# Loop de envio -----------------------------------------------------------

sids_created = tibble(sid = c(), status = c())
sids_removed = tibble(sid = c(), status = c())

for (i in unique(metadados_filt$indicator_code)) {

  df_filt <- metadados_filt %>%
    filter(indicator_code == i) %>%
    rename(grupo = 'grupo_transformação')

  #Gera todos os SIDs a partir do Subgrupo
  sids_by_group <- gen_sids_by_group(indicators_metadado = df_filt,
                                     depara_grupos = grupo_transf,
                                     depara_unidade = depara_unidade)

  #Coleta as séries já existentes na FS
  current_series_raw <- httr::VERB("GET",
                                   url = paste0(url_to_use, "api/v1/indicators/", i, "/series?limit=4000"),
                                   add_headers(token_to_use)) %>% content("parsed")

  current_series <- tibble()

  if(length(current_series_raw[['data']]) == 0){
    print(paste('Atualmente não há nenhuma abertura para o indicador', i))
  } else {
    print(paste('Atualmente há', length(current_series_raw[['data']]), 'aberturas para o indicador', i))

    for (k in 1:length(current_series_raw[['data']])) {
      sid = current_series_raw[['data']][[k]][['code']]

      current_series <- current_series %>%
        bind_rows(tibble(sid = sid))
    }

    current_series <- current_series %>%
      pluck('sid')

    #Filtros específicos em cima do grupo de transf. gerado
    #Mantem a TP + RG apenas para a combinação que já existe na FS
    tp_current <- current_series %>%
      str_sub(10,14) %>%
      unique()

    sids_to_send_metadata <- sids_by_group %>%
      filter(!(sid %in% current_series)) %>%
      #filter(str_sub(sid, 13, 13) %in% c('R', 'W'))
      filter(str_sub(sid, 10,14) %in% tp_current)
  }

  if(sids_to_send_metadata %>% nrow() != 0){

   print(paste0("Enviando as aberturas para o indicador: ", i))

   post_sid =  post_series(indicators_metadado = sids_to_send_metadata,
                           token = token_to_use,
                           url = url_to_use)

   if(any(!(post_sid$status %in% c(200, 400)))) {
     stop('Problema na criação de série para o indicador', i)
   } else {
     sids_created <- sids_created %>%
       bind_rows(post_sid)

     print(paste('As séries para o indicador', i, 'foram criadas'))
   }
  } else {
    print(paste("Não há aberturas para serem criadas para o indicador", i))
  }

  del_sids <- select_sids_to_del(indicator = i,
                                 new_sids = sids_by_group,
                                 token = token_to_use,
                                 url = url_to_use)

  if(!identical(del_sids, character(0))) {
    print(paste("Deletando aberturas indesejadas do indicador: ", i))
    delete_sid <- delete_series(indicator = i,
                                del_series = del_sids,
                                token = token_to_use,
                                url = url_to_use)

    if(any(!(delete_sid$out %in% c(200, 404)))) {
      stop('Problema na deleção de série para o indicador', i)
    } else {
      print(paste('As séries do indicador', i, 'foram deletadas com sucesso!'))
    }
  } else {
    print(paste("Sem aberturas do indicador", i, "para excluir!"))
  }
}

