#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

# install.packages("devtools")
# devtools::install_github("LuizPaulo023/fsApi", ref = "main")

#library(fsApi)

library(tidyverse)
library(httr)

# Definindo o Token do usuário - homologação ----------------------------------------------------------

token_homo = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY3NzA5MDAwNSwiZXhwIjoxNjc3MTc2NDA1LCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.m38Y-eV3FAUPegXAtNNWrS8B0RDLzqVa2U6CspwgW4A8eNZS2_Cu7h45dMK4lLj023mjojIILjPRV2kC2468yi-FrmrCcT94CopaRwRhbhLe8bg-3TQmxy57Bpg-Xgy0mexDoReReYMQq1A_GcW2jJEhsdxNZ6Y4dqc64xBXJroC65psXkKadc9De4Y6cCTkR6W_1ebXX-XccvZsCRun1F-YTNZY9dd_ynXlITS9C7uvuChBw60pzPYLoQBuJnHcUe3LrEeczZ_0404rbe3xB6sQ5C4I9ebUzg6UiZGxPp5VpLBKDlLhJ9ymuWdce5sTP0J9bUqIzeJhAsfFbaihTw',
  'Content-Type' = 'application/json'
)

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'Bearer INSIRA O TOKEN AQUI',
  'Content-Type' = 'application/json'
)

# Novas Aberturas ---------------------------------------------------------------------------------------

belle_path <- 'C:/Users/GabrielBelle/4intelligence/Feature Store - Documentos/DRE/Documentação/migracao'

indicators_raw <- readxl::read_excel('grupos_transfs_FS.xlsx') %>%
                  select(codigo, grupo, subgrupo, regioes)

indicators <- indicators_raw %>%
  filter(grupo == 'Juros') %>%
  mutate(grupo = paste0(grupo, ' - ', subgrupo),
         regioes = ifelse(regioes == '0', '000', regioes))

grupo_transf <- readxl::read_excel(paste0(belle_path,
                                          '/diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>%
  pivot_longer(cols = everything(),
               names_to = 'grupo',
               values_to = 'transfs') %>%
  arrange(grupo) %>%
  filter(!is.na(transfs))

indicators_to_send <- indicators %>%
  left_join(grupo_transf) %>%
  mutate(transf_sec = str_sub(transfs, 4,4),
         unit_pt = case_when(
           transf_sec == 'X' ~ '% a.d',
           transf_sec == 'N' ~ '% a.a',
           transf_sec == 'G' ~ '% a.a'
         ),
         unit_en = case_when(
           transf_sec == 'X' ~ '% p.d',
           transf_sec == 'N' ~ '% p.a',
           transf_sec == 'G' ~ '% p.a'
         ))

for (i in unique(indicators_to_send$codigo)) {

  fsApi::delete_series(indicator = i,
                       token = token_homo)

  df_filt <- indicators_to_send %>%
    filter(codigo == i)

  send_transf = fsApi::post.series(indicator_code = i,
                            region_code = unique(df_filt$regioes),
                            transfs_code = unique(df_filt$transfs),
                            units_en = unique(df_filt$unit_en),
                            units_pt = unique(df_filt$unit_pt),
                            token = token_homo)

}



