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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY3OTk0NzYwNSwiZXhwIjoxNjgwMDM0MDA1LCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.EUEsN2d_kL4YHuKqsHgy-rl6GxSJiDPKH0iS4X1m0rsl5bOZ-IZ-gSpBu-c7_wmS7QwfVrXT17Tsf8_P3ZFDQaIrpYvPP8NhHU0cS2Mb7sdo-wy_8DQiW0alj1-lXE4DaOEMh_YcwSy3uX_MoLPoOPJShg7hWMHAz7u5vaHfNlYbSVIHjmFQkT9gNwELAhD9WrOSzp2EqNVUnyzqNPs6X1nyWeXKpIhKzADBKpct5__IYwr2lbLOYGmEsNdYgcLDa_LT4TQ_DGsHHCSzMDUuncp680w2LYxjv8TXD0rXsemeW6RBOZ_iL4Gc0wlreDaVhQMD0Lm8yUMwpoR-FuILVQ',
  'Content-Type' = 'application/json'
)

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNFZGl0b3IiLCJpczRpIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJiZG1nIl19LCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYyMzRjNDI0YTE4ZjM3MDA2OGI3MTFkOSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjc5OTI2NzM5LCJleHAiOjE2ODI1MTg3MzksImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.J7eMgfUtrERaBGpAwRZXc82-xgdYEtLtvx6ZXOg66_TG0qJy1OXPIzhM2JJLaR7s1wnCn-FHN0AmzA6Z_CDebvm6XO7CSGpAhzjEyAyCy5qmeHYt3sbEQwu2sACvtmGjtgNX7-6Fijj8eNyk-8C7m8H_gwbtqmvf7BT1FxxAK_NbEYBYwkNdGvdAFYgIWi-Ci6Gb9nHvjBWcaGo9bwazPkVLq4cojdO84OvlzuG_45HTiR7MgkrHv9gSnTFk8AOcKvzmFIXVHMQ81_eqpQQc3mfS7x1pAclV8xMr3LgBp7XU8wl2JYnkjf__j-el84vBY5GnD72qe8t1Qe28ff6NCw',
  'Content-Type' = 'application/json'
)

# Novas Aberturas ---------------------------------------------------------------------------------------
# ATENÇÃO ADICIONAR NOVAS PARÂMETROS AO CHAMAR A FUNÇÃO:

#' send_transf = fsApi::post.series(indicator_code = "BRBOP0001",
#'                                  region_code = c('AL2', 'GO2'),
#'                                  transfs_code = c("OOML", "OOMM"),
#'                                  units_en = c("teste1", "teste2"),
#'                                  units_pt = c("testea", "testeb")
#'                                  token = headers)


# Retorna os nós (mestres) presentes na FS -------------------------------------------

node_matres = fsApi::get.master_node(token = token_prod)

# Requisitando a árvore FS (prod) --------------------------------------------------------------------

tree_all = fsApi::get.tree(master_node = "all",
                           token = token_prod)

db_tree = fsApi::get.tree(master_node = "Brazil",
                          token = token_prod)

# Consultando o body que precisa ser preenchido --------------------------------------------

fsApi::get.body()

# Criando indicadores -----------------------------------------------------------------------------------------
# ATENÇÃO: A FUNÇÃO POST.INDICATOR É DEPENDENTE DAS FUNÇÕES {get.tree} e {get.id}

library(fsApi)

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
                                  country = "AR",
                                  sector = "BOP",
                                  acess_group = "Geral",
                                  node_en = "Argentina",
                                  node_pt = "Argentina")
# ---------------------------------------------------------------------------------------

