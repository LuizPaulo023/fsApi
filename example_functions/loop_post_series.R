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
  'Authorization' = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL25hbWUiOiJnLmJlbGxlQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaXNzIjoiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjI5OGY5ZTM4YWU1Y2UwMDY5MDcwNjAyIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNzE4NzI1NjUyLCJleHAiOjE3MTg4MTIwNTIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInBlcm1pc3Npb25zIjpbImFzazpxdWVzdGlvbnMiLCJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0Omdyb3VwLWFsZXJ0cyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDpncm91cC1hbGVydHMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.JU4QxLJXzcwQxVgWJNzNjv9RFOEdxe9dvWWMqeKNAupYBf7PiCTHJzAs4Rm3UQ13k_XARluVWeeM6-enPwrywb7VcUjn4bW_Sxqfn_c1hCBZx9Gbb16Tv-WWp3MXzcVierm8IAKC-aTy_c6SjI0FjJBfBwLX0NTtpPK1URyYYqvp0M4HuX28uhokYjzHg2M9cZPP9MuMtiNd0TijpucDWK9_EehZ6KxIl4C585nTpGkjGQy2FiWHzGfXzPC_kaawzGZu454ZJhUjrbZGa1mzLjAZyaYmYmIbCrEQshKBsUFTeE8WCcBKEcU0cyMZ8L_wBsUtxhaqFxZ9euLKfZYPoA',
  'Content-Type' = 'application/json'
)

# Escolha o ambiente prod ou stg #\ opções: stg, prod

url_to_use = urls(environment = "stg_apigee")

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


# Criar SIDs inexistentes - TP ---------------------------------------

indicadores <- readxl::read_excel(paste0(user, path,
                                          'indicador_grupo_transfs.xlsx'))

migracao_tp <- readxl::read_excel(paste0(user, path,
                                         'Migração TP.xlsx')) %>%
  janitor::clean_names() %>%
  filter(crawler == 'sgs_credito')

metadados_filt <- indicadores %>%
  filter(indicator_code %in% migracao_tp$indicador)

metadados_filt$grupo_transformação %>% unique()

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
                                     depara_unidade = depara_unidade) %>%
    filter(!(!(str_sub(sid, 10, 12) == "000") & str_sub(sid, 16, 16) == "P"))

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
      filter(!(sid %in% current_series))
      #filter(str_sub(sid, 13, 13) %in% c('R', 'W'))
      #filter(str_sub(sid, 10,14) %in% tp_current)
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

