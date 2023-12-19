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
  'Authorization' = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImwudGF2YXJlc0A0aW50ZWxsaWdlbmNlLmNvbS5iciIsImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTcwMjM5NzExNywiZXhwIjoxNzAyNDgzNTE3LCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.ZRVEc73JDZhJG2o1DgG62m4P1FItQEcLA7kom_c81y4sM9NgQ3g_239k9BDbtfbVGknDp0dgg_iMBQxFQydJOHMW76YRdWQTPfHm9yXgt4cwOkQ-WCMI9Kdn8mfRaJVfrCtKir0rR4RTuHM46m1HhMbqzJMA3aZlgYYozFyPf_dN-N_LOXzpXNqMN5ZkXvaykpx0DuwDbrRy_Q-5BYM_S-jfoWcyO3rgvEm-xo7KOnZP0FqpPo6OtBSn0l2EsAtTg87vfx0yCTNGHlKlNAtJnGWCPfipi_XAr3c6MQF0-TiMRacn15sjqtK6NmHXx2qkMGvAOIAb_lhkFxbeBswmBA',
  'Content-Type' = 'application/json'
)

# Escolha o ambiente prod ou stg #\ opções: stg, prod
url_to_use = urls(environment = "stg")

# Anbima -----------------------------------------------------------------

metadados_filt <- readxl::read_excel('anbima/novos_indicadores.xlsx') %>%
  janitor::clean_names()
# %>%
#   filter(indicator_code == "BRANBCD41")


# metadados_filt <- metadados %>%
#   left_join(periodicidade_historico)

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

for (i in unique(metadados_filt$indicator_code)) {
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


