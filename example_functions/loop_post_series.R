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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL25hbWUiOiJnLmJlbGxlQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaXNzIjoiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjI5OGY5ZTM4YWU1Y2UwMDY5MDcwNjAyIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjk5NjIyNTM1LCJleHAiOjE2OTk3MDg5MzUsImF6cCI6IktRbWV2dXdJUW81WXdLRm9vR0NVclVmc0VVaTh5SzM0Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImFzazpxdWVzdGlvbnMiLCJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.Q757QuKGG5ghTqv49mx-YueboROXGqbC236iCL8UO9C6j3ns_9c-v2NcDyZMosOQCYDdq-YmoTseZLtIF7SbBQGk83F8CTXbWFzlZ_79l7k_X2HNA0nsPjlikMgRzN0FtqQVF53lkbF2z3BEDABdPcpC_BjgrB2jwmltmdAcoPNPqWe68fREAyS90zsXCwrD2PlI5HdnvdpE-089ZNk_kn6Ybfpg4atss6bTDEuIjM0lLnSmK8AKzxvJzdeP4mW6zEiPqCnxqkpgLaqzUc_wK7yQ7AqXXKZzpN4VZBcx8Z8JTdg97wnFoncm_UMho1tPenA96IuVn-LGqq4dxQZ-uQ',
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


# Criar SIDs inexistentes - Buracos ---------------------------------------

ind_stg <- readxl::read_excel(paste0(user, path,
                                          'ind_stg.xlsx')) %>%
  pluck('indicator_code')

metadados_filt <- readxl::read_excel(paste0(user, path,
                                            'indicador_grupo_transfs.xlsx')) %>%
  filter(indicator_code %in% ind_stg)

# Anbima -----------------------------------------------------------------
#
# metadados_filt <- readxl::read_excel('anbima/indicadores_mensais_anuais.xlsx') %>%
#   janitor::clean_names() %>%
#   filter(frequencia == "ANUAL") %>%
#   rename(indicator_code = indicador) %>%
#   bind_rows(tibble(indicator_code = 'BRANBH735')) %>%
#   tail(1)
#
# sids_anbima = tibble(
#   sid = c('CTOOODL', 'CTOOSML', 'CTOOSMI', 'CTOOSMC', 'CTOOSQL', 'CTOOSQI', 'CTOOSQC', 'CTOOSYL',
#           'CTOOAML', 'CTOOAQL', 'CTOOAYL',
#           'RSGOODL', 'RSGOSML', 'RSGOSMI', 'RSGOSMC', 'RSGOSQL', 'RSGOSQI', 'RSGOSQC', 'RSGOSYL',
#           'RSGOAML', 'RSGOAQL', 'RSGOAYL',
#           'CTLOODL', 'CTLOSML', 'CTLOSMI', 'CTLOSMC', 'CTLOSQL', 'CTLOSQI', 'CTLOSQC', 'CTLOSYL',
#           'CTLOAML', 'CTLOAQL', 'CTLOAYL',
#           'PTLOODL', 'PTLOODY', 'PTLOODM', 'PTLOODV', 'PTLOODO', 'PTLOODU',
#           'PTLOEMV', 'PTLOEMU', 'PTLOAMV', 'PTLOAMU', 'PTLOEQV', 'PTLOEQU', 'PTLOAQV', 'PTLOAQU',
#           'PTLOEML', 'PTLOEMM', 'PTLOEMY', 'PTLOEQL', 'PTLOEQM', 'PTLOEQY', 'PTLOEYL', 'PTLOEYY',
#           'PTLOAML', 'PTLOAMM', 'PTLOAMY', 'PTLOAQL', 'PTLOAQM', 'PTLOAQY', 'PTLOAYL', 'PTLOAYY',
#           'NMCOODL', 'NMCOEML', 'NMCOEMM', 'NMCOEMY', 'NMCOEQL', 'NMCOEQM', 'NMCOEQY', 'NMCOEYL', 'NMCOEYY',
#           'NMCOAML', 'NMCOAMM', 'NMCOAMY', 'NMCOAQL', 'NMCOAQM', 'NMCOAQY', 'NMCOAYL', 'NMCOAYY',
#           'VRCOODL', 'VRCOODY', 'VRCOODM', 'VRCOODV', 'VRCOODO', 'VRCOODU',
#           'VRCOEMV', 'VRCOEMU', 'VRCOAMV', 'VRCOAMU', 'VRCOEQV', 'VRCOEQU', 'VRCOAQV', 'VRCOAQU',
#           'VRCOEML', 'VRCOEMM', 'VRCOEMY', 'VRCOEQL', 'VRCOEQM', 'VRCOEQY', 'VRCOEYL', 'VRCOEYY',
#           'VRCOAML', 'VRCOAMM', 'VRCOAMY', 'VRCOAQL', 'VRCOAQM', 'VRCOAQY', 'VRCOAYL', 'VRCOAYY'
#   ),
#   # sid = c('CTOOOML', 'CTOOOMC',
#   #         'CTOOSQL', 'CTOOSQC', 'CTOOSYL',
#   #         'CTOOAQL', 'CTOOAYL',
#   #         'RSGOOML', 'RSGOOMC',
#   #         'RSGOSQL', 'RSGOSQC', 'RSGOSYL',
#   #         'RSGOAQL', 'RSGOAYL',
#   #         'CTLOOML', 'CTLOOMC',
#   #         'CTLOSQL', 'CTLOSQC', 'CTLOSYL',
#   #         'CTLOAQL', 'CTLOAYL',
#   #         'PTLOOML', 'PTLOOMM', 'PTLOOMY',
#   #         'PTLOEQL', 'PTLOEQM', 'PTLOEQY', 'PTLOEYL', 'PTLOEYY',
#   #         'PTLOAQL', 'PTLOAQM', 'PTLOAQY', 'PTLOAYL', 'PTLOAYY',
#   #         'NMCOOML', 'NMCOOMM', 'NMCOOMY',
#   #         'NMCOEQL', 'NMCOEQM', 'NMCOEQY', 'NMCOEYL', 'NMCOEYY',
#   #         'NMCOAQL', 'NMCOAQM', 'NMCOAQY', 'NMCOAYL', 'NMCOAYY',
#   #         'VRCOOML', 'VRCOOMM', 'VRCOOMY',
#   #         'VRCOEQL', 'VRCOEQM', 'VRCOEQY', 'VRCOEYL', 'VRCOEYY',
#   #         'VRCOAQL', 'VRCOAQM', 'VRCOAQY', 'VRCOAYL', 'VRCOAYY'
#   # ),
#   # sid = c('CTOOOYL', 'RSGOOYL', 'CTLOOYL', 'PTLOOYL', 'PTLOOYY', 'NMCOOYL', 'NMCOOYY', 'VRCOOYL', 'VRCOOYY'),
#   un_pt = case_when(
#     str_sub(sid, 1, 3) == 'NMC' & str_sub(sid, 7,7) == 'L' ~ 'Pessoas',
#     str_sub(sid, 7,7) %in% c('L', 'C', 'I') ~ 'R$',
#     str_sub(sid, 7,7) != 'L' ~ '%'),
#   un_en = case_when(
#     str_sub(sid, 1, 3) == 'NMC' & str_sub(sid, 7,7) == 'L' ~ 'People',
#     str_sub(sid, 7,7) %in% c('L', 'C', 'I') ~ 'R$',
#     str_sub(sid, 7,7) != 'L' ~ '%')
# )


# Loop de envio -----------------------------------------------------------

problems = tibble(sid = c(), status = c())
sids_to_del <- tibble(ind = c(), sids = c())

for (i in unique(metadados_filt$indicator_code)) {

  df_filt <- metadados_filt %>%
    filter(indicator_code == i) %>%
    rename(grupo = 'grupo_transformação')


  #Gera todos os SIDs a partir do Subgrupo
  sids_by_group <- gen_sids_by_group(indicators_metadado = df_filt,
                                     depara_grupos = grupo_transf,
                                     depara_unidade = depara_unidade)

  current_series_raw <- httr::VERB("GET",
                                   url = paste0(url_to_use, "api/v1/indicators/", i, "/series?limit=4000"),
                                   add_headers(token_to_use)) %>% content("parsed")

  current_series <- tibble()

  if(length(current_series_raw[['data']]) == 0){
    F
  } else {
    for (i in 1:length(current_series_raw[['data']])) {
      sid = current_series_raw[['data']][[i]][['code']]

      current_series <- current_series %>%
        bind_rows(tibble(sid = sid))
    }

    current_series <- current_series %>%
      pluck('sid')

    #Filtros específicos em cima do grupo de transf. gerado
    tp_current <- current_series %>%
      str_sub(10,14) %>%
      unique()

    sids_to_send_metadata <- sids_by_group %>%
      filter(!(sid %in% current_series)) %>%
      filter(str_sub(sid, 10,14) %in% tp_current)
  }

  # sids_to_send_metadata <- sids_anbima %>%
  #   mutate(sid = paste0(i, sid))

  print(paste0("Enviando as aberturas para o indicador: ", i))

  if(sids_to_send_metadata %>% nrow() != 0){

   post_sid =  post_series(indicators_metadado = sids_to_send_metadata,
                           token = token_to_use,
                           url = url_to_use)
  } else {
    F
  }

  # del_sids <- select_sids_to_del(indicator = i,
  #                                new_sids = sids_to_send_metadata,
  #                                token = token_to_use,
  #                                url = url_to_use)
  #
  # if(!identical(del_sids, character(0))) {
  #   print(paste0("Deletando aberturas indesejadas do indicador: ", i))
  #   delete_series(indicator = i,
  #                 del_series = del_sids,
  #                 token = token_to_use,
  #                 url = url_to_use)
  # } else {
  #   print(paste0("Sem aberturas para excluir para o indicador ", i))
  # }
}


