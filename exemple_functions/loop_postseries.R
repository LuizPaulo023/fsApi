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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNFZGl0b3IiLCJpczRpIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImlzcyI6Imh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjIzNGM0MjRhMThmMzcwMDY4YjcxMWQ5IiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2NzUxODcwMzcsImV4cCI6MTY3Nzc3OTAzNywiYXpwIjoibVNLWnFINUtxMVdvY3hKY2xuSVVSYlZJS1VXUmpvSnoiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.VFGsaYgLSHvcn5ej33guxsUCGXUiP3lpDddNGSyGmxNRw74OF3SF-_KcnCU4u1Vk8UyU5xXnOxIacmjB7WiDskELguUQ8AUXxZsVi93Nc_vzcSmTtkv3YlpVGkO9eyRl422mh9nf83cvQbri9zXphQg8TEZNFcY5ndelG-cfQJqXCXUrLHtBBdvGjLWwAVekTtqT3wYYO7OtIWe9Wd_WaQb4bEQxNOxV84SubCBKguqN5ay19Nh35XfoV8cuUTmm3L7EDI-cegBlRvJ2SXeCcQuyl52nmmSovGtTU8yOgzzJMJ4IgFESWhM8rOJoIxALYbsHyXXkAv3osn7ekuZcHQ',
  'Content-Type' = 'application/json'
)

# Novas Aberturas ---------------------------------------------------------------------------------------

belle_path <- 'C:/Users/GabrielBelle/4intelligence/Feature Store - Documentos/DRE/Documentação/migracao'

indicators_raw <- readxl::read_excel(paste0(belle_path,
                                            '/grupos_transfs_FS.xlsx')) %>% 
  select(codigo, grupo, subgrupo, regioes, starts_with('original_'), starts_with('real_')) %>% 
  mutate(grupo = paste0(grupo, ' - ', subgrupo),
         regioes = ifelse(regioes == '0', '000', regioes))


indicators <- indicators_raw %>% 
  filter(codigo %in% c('BRFXR0015','BRFXR0021','BRFXR0005'))
  
grupo_transf <- readxl::read_excel(paste0(belle_path, 
                                          '/diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>% 
  pivot_longer(cols = everything(), names_to = 'grupo', values_to = 'transfs') %>% 
  arrange(grupo) %>% 
  filter(!is.na(transfs))

depara_unidade <- readxl::read_excel(paste0(belle_path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida') 

indicators_to_send <- indicators %>% 
  left_join(grupo_transf) %>% 
  mutate(cod1_cod2 = paste0(str_sub(transfs, 1,1),
                            transf_sec = str_sub(transfs, 4,4))) %>% 
  left_join(depara_unidade) %>% 
  rowwise() %>% 
  mutate(un_pt = ifelse(is.na(un_pt),
                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_pt, real_pt),
                        un_pt),
         un_en = ifelse(is.na(un_en),
                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_en, real_en),
                        un_en))

if(any(is.na(indicators_to_send$un_pt)) | any(is.na(indicators_to_send$un_en))) {
  na_un <- indicators_to_send %>% 
    filter(is.na(un_pt) | is.na(un_en)) %>% 
    distinct(codigo) %>% 
    pluck('codigo')
  
  stop(paste0('Os seguintes indicadores não possuem unidade de medida preenchida: ', na_un))
}

for (i in unique(indicators_to_send$codigo)) {
  df_filt <- indicators_to_send %>% 
    filter(codigo == i)
  
  send_transf = post.series(indicator_code = i,
                                   region_code = unique(df_filt$regioes),
                                   transfs_code = unique(df_filt$transfs),
                                   units_en = unique(df_filt$unit_en),
                                   units_pt = unique(df_filt$unit_pt),
                                   token = token_homo)
  
}