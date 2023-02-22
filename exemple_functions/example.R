#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

rm(list = ls())
graphics.off()

# install.packages("devtools")
# devtools::install_github("LuizPaulo023/fsApi", ref = "main")

library(fsApi)
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

send_transf = fsApi::post.series(indicator_code = "BRIND0046",
                                 transfs_code = c("RJ2OOML",
                                                  "SP2OOML"),
                                 units_en = c("teste_Índice",
                                              "teste_Índice"),
                                 units_pt = c("teste_pt",
                                              "teste_pt"),
                                 token = token_homo)

# Retorna os nós (mestres) presentes na FS -------------------------------------------

fsApi::get.master_node(token = token_prod)

# Requisitando a árvore FS (prod) --------------------------------------------------------------------

tree_all = fsApi::get.tree(master_node = "all",
                           token = token_prod)

db_tree = fsApi::get.tree(master_node = "Brazil",
                          token = token_prod)

# Consultando o body que precisa ser preenchido --------------------------------------------

fsApi::get.body()

# Criando indicadores -----------------------------------------------------------------------------------------
#apply(table_complet, 1, post.indicator)


send_indicadores = post.indicator(name_en = "ARG - Exports of Goods",
                                  name_pt = "ARG - Exportações de Bens",
                                  short_en = "Export. Goods",
                                  short_pt = "Exp. Bens",
                                  source_en = "Indec",
                                  source_pt = "Indec",
                                  description_en = "....",
                                  description_pt = "...",
                                  description_full_en = "...",
                                  description_full_pt = "...",
                                  # Refatorar, retirar unit ----
                                  #unit = "USD Milhões",
                                  country = "AR",
                                  sector = "BOP",
                                  acess_group = "Geral",
                                  id_node = list_id)
# ---------------------------------------------------------------------------------------

if(){
  final(N) >> %a.a
}

depara <- tibble(cod_4 = c(X, N, G),
                 unidade_pt = c('%a.d', '%a.a', '%a.a'))

if(!(cod_indicador_4 %in% depara$cod_4)){pego o preenchimento da planilha}

