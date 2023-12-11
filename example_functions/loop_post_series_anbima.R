#' @title Envio de séries/aberturas de fundos Anbima para FS

pacman::p_load(tidyverse, httr)

# Configurações de ambiente do usuário
user = base::getwd() %>%
       stringr::str_extract("^((?:[^/]*/){3})") %>% print()

path <- '4intelligence/Feature Store - Documentos/DRE/curadoria/'
setwd(paste0(user,path))

# Definindo parâmetros do usuário ----------------------------------------------------------
source("urls.R")
token_to_use = c(
  'Authorization' = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL25hbWUiOiJnLmJlbGxlQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaXNzIjoiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjI5OGY5ZTM4YWU1Y2UwMDY5MDcwNjAyIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNzAxNzg1MjQ0LCJleHAiOjE3MDE4NzE2NDQsImF6cCI6IktRbWV2dXdJUW81WXdLRm9vR0NVclVmc0VVaTh5SzM0Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImFzazpxdWVzdGlvbnMiLCJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.AdYQTgVqo8rFQQOVngqR20f1WnY5mZ8U1x9yey4ovk8LupwtQ80HPwFMqdRdii20p84OUKlbCIg1uzCwThcyn1N5ZE5e-qNWqt4r7goxkOeB7lnOMdIWSsIdgxE2Hv72zfGPaWgNMGqlX8cp-nmL-dYs1u-FwQ1JvL1ck6f2NzaK5YxSGO80NsQsH8j050Dbh6nhvLk8ObuzCWKUwl3Rq5pdWxOkgeFGWSLLr6bNgaJ3p_e1NyElAwSgOYYh6sYKw1O7Ukkqvh1Vlnp6k9fJcwl_UOjp2ufxJlJ4hcucWCYrG9-2h9lBs5jnn2g4I6QnxtbAqswc6lmBwLk2C7hzIw',
  'Content-Type' = 'application/json'
)

# Escolha o ambiente prod ou stg #\ opções: stg, prod
url_to_use = urls(environment = "stg")

# Anbima -----------------------------------------------------------------

metadados <- readxl::read_excel('anbima/novos_indicadores.xlsx') %>%
  janitor::clean_names()

#Excel do Andre. Trocar pelo excel do BI
periodicidade_historico <- readxl::read_excel('anbima/periodicidade_novos_fundos_2023-12-04.xlsx') %>%
  #Calcula o tamanho da idade do fundo
  mutate(tamanho = data_registro_atual - data_inicio,
         tamanho = ifelse(is.na(tamanho),
                          as.POSIXct(Sys.Date(), format = '%y-%m-%d') - data_inicio,
                          tamanho),
         tamanho = as.numeric(tamanho)
         ) %>%
  #Não SUBIR fundos menos de 33 dias de periodidade
  #não criar o indicador
  select(-c(data_registro_atual, data_inicio, codigo_fundo)) %>%
  rename(frequencia = periodicidade) %>%
  mutate(frequencia = case_when(frequencia == 'DIARIA' ~ 'D',
                                frequencia == 'MENSAL' ~ 'M',
                                frequencia == 'ANUAL' ~ 'Y'))

metadados_filt <- metadados %>%
  left_join(periodicidade_historico)

sids_anbima = list(
  diario = c(
    #Rentabilidade (variação da cota)
    'RTNOODY', 'RTNOODM', 'RTNOODV', 'RTNOODU', 'RTNOODO',
    'RTNOEMV', 'RTNOEMU', 'RTNOEQV', 'RTNOEQU',
    'RTNOEMM', 'RTNOEMY', 'RTNOEQM', 'RTNOEQY', 'RTNOEYY',
    'RTNOAMV', 'RTNOAMU', 'RTNOAQV', 'RTNOAQU',
    'RTNOAMM', 'RTNOAMY', 'RTNOAQM', 'RTNOAQY', 'RTNOAYY',
    #Valor da cota
    'VRCOODL',
    'VRCOEML', 'VRCOEQL', 'VRCOEYL',
    'VRCOAML', 'VRCOAQL', 'VRCOAYL',
    #Captação
    'CTOOODL',
    'CTOOSML', 'CTOOSMC', 'CTOOAML',
    'CTOOSQL', 'CTOOSQC', 'CTOOAQL',
    'CTOOSYL', 'CTOOAYL',
    #Resgate
    'RSGOODL',
    'RSGOSML', 'RSGOSMC', 'RSGOAML',
    'RSGOSQL', 'RSGOSQC', 'RSGOAQL',
    'RSGOSYL', 'RSGOAYL',
    #Captação Líquida
    'CTLOODL',
    'CTLOSML', 'CTLOSMC', 'CTLOAML',
    'CTLOSQL', 'CTLOSQC', 'CTLOAQL',
    'CTLOSYL', 'CTLOAYL',
    #Patrimônio Líquido
    'PTLOODL', 'PTLOODY', 'PTLOODM', 'PTLOODV', 'PTLOODU', 'PTLOODO',
    'PTLOEMV', 'PTLOEMU', 'PTLOEQV', 'PTLOEQU',
    'PTLOEML', 'PTLOEMM', 'PTLOEMY', 'PTLOEQL', 'PTLOEQM', 'PTLOEQY', 'PTLOEYL', 'PTLOEYY',
    'PTLOAMV', 'PTLOAMU', 'PTLOAQV', 'PTLOAQU',
    'PTLOAML', 'PTLOAMM', 'PTLOAMY', 'PTLOAQL', 'PTLOAQM', 'PTLOAQY', 'PTLOAYL', 'PTLOAYY',
    #Número de cotistas
    'NMCOODL', 'NMCOODY',
    'NMCOEML', 'NMCOEMM', 'NMCOEMY',
    'NMCOEQL', 'NMCOEQM', 'NMCOEQY',
    'NMCOEYL', 'NMCOEYY',
    'NMCOAML', 'NMCOAMM', 'NMCOAMY',
    'NMCOAQL', 'NMCOAQM', 'NMCOAQY',
    'NMCOAYL', 'NMCOAYY'
  ),
  semanal = c(
    #Rentabilidade (variação da cota)
    'RTNOOWY', 'RTNOOWM', 'RTNOOWV', 'RTNOOWU',
    'RTNOEMV', 'RTNOEMU', 'RTNOEQV', 'RTNOEQU',
    'RTNOEMM', 'RTNOEMY', 'RTNOEQM', 'RTNOEQY', 'RTNOEYY',
    'RTNOAMV', 'RTNOAMU', 'RTNOAQV', 'RTNOAQU',
    'RTNOAMM', 'RTNOAMY', 'RTNOAQM', 'RTNOAQY', 'RTNOAYY',
    #Valor da cota
    'VRCOOWL',
    'VRCOEML', 'VRCOEQL', 'VRCOEYL',
    'VRCOAML', 'VRCOAQL', 'VRCOAYL',
    #Captação
    'CTOOOWL',
    'CTOOSML', 'CTOOSMC', 'CTOOAML',
    'CTOOSQL', 'CTOOSQC', 'CTOOAQL',
    'CTOOSYL', 'CTOOAYL',
    #Resgate
    'RSGOOWL',
    'RSGOSML', 'RSGOSMC', 'RSGOAML',
    'RSGOSQL', 'RSGOSQC', 'RSGOAQL',
    'RSGOSYL', 'RSGOAYL',
    #Captação Líquida
    'CTLOOWL',
    'CTLOSML', 'CTLOSMC', 'CTLOAML',
    'CTLOSQL', 'CTLOSQC', 'CTLOAQL',
    'CTLOSYL', 'CTLOAYL',
    #Patrimônio Líquido
    'PTLOOWL', 'PTLOOWY', 'PTLOOWM', 'PTLOOWV', 'PTLOOWU',
    'PTLOEMV', 'PTLOEMU', 'PTLOEQV', 'PTLOEQU',
    'PTLOEML', 'PTLOEMM', 'PTLOEMY', 'PTLOEQL', 'PTLOEQM', 'PTLOEQY',  'PTLOEYL', 'PTLOEYY',
    'PTLOAMV', 'PTLOAMU', 'PTLOAQV', 'PTLOAQU',
    'PTLOAML', 'PTLOAMM', 'PTLOAMY', 'PTLOAQL', 'PTLOAQM', 'PTLOAQY', 'PTLOAYL', 'PTLOAYY',
    #Número de cotistas
    'NMCOOWL', 'NMCOOWY',
    'NMCOEML', 'NMCOEMM', 'NMCOEMY',
    'NMCOEQL', 'NMCOEQM', 'NMCOEQY',
    'NMCOEYL', 'NMCOEYY',
    'NMCOAML', 'NMCOAMM', 'NMCOAMY',
    'NMCOAQL', 'NMCOAQM', 'NMCOAQY',
    'NMCOAYL', 'NMCOAYY'
  ),
  mensal = c(
    #Rentabilidade (variação da cota)
    'RTNOOMY', 'RTNOOMM', 'RTNOOMV', 'RTNOOMU',
    'RTNOEQV', 'RTNOEQU',
    'RTNOEQM', 'RTNOEQY', 'RTNOEYY',
    'RTNOAQV', 'RTNOAQU',
    'RTNOAQM', 'RTNOAQY', 'RTNOAYY',
    #Valor da cota
    'VRCOOML',
    'VRCOEQL', 'VRCOEYL',
    'VRCOAQL', 'VRCOAYL',
    #Captação
    'CTOOOML',
    'CTOOSQL', 'CTOOSQC', 'CTOOAQL',
    'CTOOSYL', 'CTOOAYL',
    #Resgate
    'RSGOOML',
    'RSGOSQL', 'RSGOSQC', 'RSGOAQL',
    'RSGOSYL', 'RSGOAYL',
    #Captação Líquida
    'CTLOOML',
    'CTLOSQL', 'CTLOSQC', 'CTLOAQL',
    'CTLOSYL', 'CTLOAYL',
    #Patrimônio Líquido
    'PTLOOML', 'PTLOOMY', 'PTLOOMM', 'PTLOOMV', 'PTLOOMU',
    'PTLOEQV', 'PTLOEQU',
    'PTLOEQL', 'PTLOEQM', 'PTLOEQY', 'PTLOEYL', 'PTLOEYY',
    'PTLOAQV', 'PTLOAQU',
    'PTLOAQL', 'PTLOAQM', 'PTLOAQY', 'PTLOAYL', 'PTLOAYY',
    #Número de cotistas
    'NMCOOML', 'NMCOOMY', 'NMCOOMM',
    'NMCOEQL', 'NMCOEQM', 'NMCOEQY',
    'NMCOEYL', 'NMCOEYY',
    'NMCOAQL', 'NMCOAQM', 'NMCOAQY',
    'NMCOAYL', 'NMCOAYY'
  ),
  anual = c(
    #Rentabilidade (variação da cota)
    'RTNOOYY', 'RTNOOYV',
    #Valor da cota
    'VRCOOYL',
    #Captação
    'CTOOOYL',
    #Resgate
    'RSGOOYL',
    #Captação Líquida
    'CTLOOYL',
    #Patrimônio Líquido
    'PTLOOYL', 'PTLOOYY',
    #Número de cotistas
    'NMCOOYL', 'NMCOOYY'
  )
)

# Loop de envio -----------------------------------------------------------

problems = tibble(sid = c(), status = c())
sids_to_del <- tibble(ind = c(), sids = c())

for (i in unique(metadados_filt$indicator_code)[6:928]) {
  #i = unique(metadados_filt$indicator_code)[1]

  df_filt <- metadados_filt %>%
    filter(indicator_code == i)

  if(df_filt$frequencia == 'D') {
    sids_use <- paste0(df_filt$indicator_code, sids_anbima$diario)
  } else if(df_filt$frequencia == 'W') {
    sids_use <- paste0(df_filt$indicator_code, sids_anbima$semanal)
  }else if(df_filt$frequencia == 'M') {
    sids_use <- paste0(df_filt$indicator_code, sids_anbima$mensal)
  }else if(df_filt$frequencia == 'Y') {
    sids_use <- paste0(df_filt$indicator_code, sids_anbima$anual)
  }

  sids_by_group <- tibble(sid = sids_use) %>%
    mutate(
      un_pt = case_when(
        str_sub(sid, 10, 12) == 'NMC' & str_sub(sid, 16, 16) == 'L' ~ 'Pessoas',
        str_sub(sid, 16, 16) %in% c('L', 'C', 'I') ~ 'R$',
        str_sub(sid, 16, 16) != 'L' ~ '%'),
      un_en = case_when(
        str_sub(sid, 10, 12) == 'NMC' & str_sub(sid, 16, 16) == 'L' ~ 'People',
        str_sub(sid, 16, 16) %in% c('L', 'C', 'I') ~ 'R$',
        str_sub(sid, 16, 16) != 'L' ~ '%')
    )

  if(df_filt$tamanho <= 95) {
    agg_per_rm <- c('AQ', 'EQ', 'AY', 'EY')
    ts_rm <- c('U', 'Y', 'C')
  } else if(df_filt$tamanho <= 366) {
    agg_per_rm <- c('AY', 'EY')
    ts_rm <- c('Y', 'C')
  } else {
    agg_per_rm <- c()
    ts_rm <- c()
  }

  sids_by_group <- sids_by_group %>%
    filter(
      !(str_sub(sid, 14,15) %in% agg_per_rm),
      !(str_sub(sid, 16, 16) %in% ts_rm)
    )

  current_series_raw <- httr::VERB("GET",
                                   url = paste0(url_to_use, "api/v1/indicators/", i, "/series?limit=4000"),
                                   add_headers(token_to_use)) %>% content("parsed")

  current_series <- tibble()

  if(length(current_series_raw[['data']]) == 0){
    sids_to_send_metadata <- sids_by_group
  } else {
    for (k in 1:length(current_series_raw[['data']])) {
      sid = current_series_raw[['data']][[k]][['code']]

      current_series <- current_series %>%
        bind_rows(tibble(sid = sid))
    }

    current_series <- current_series %>%
      pluck('sid')

    sids_to_send_metadata <- sids_by_group %>%
      filter(!(sid %in% current_series))
  }

  print(paste0("Enviando as aberturas para o indicador: ", i))

  if(sids_to_send_metadata %>% nrow() != 0){

   post_sid =  post_series(indicators_metadado = sids_to_send_metadata,
                           token = token_to_use,
                           url = url_to_use)
  } else {
    print(paste0("Sem aberturas novas para enviar, para o indicador ", i))
  }

  del_sids <- select_sids_to_del(indicator = i,
                                 new_sids = sids_by_group,
                                 token = token_to_use,
                                 url = url_to_use)

  if(!is.null(del_sids)) {
    print(paste0("Deletando aberturas indesejadas do indicador: ", i))
    delete_series(indicator = i,
                  del_series = del_sids,
                  token = token_to_use,
                  url = url_to_use)
  } else {
    print(paste0("Sem aberturas para excluir para o indicador ", i))
  }
}


