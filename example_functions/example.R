#' @title Alterando aberturas/transformações presentes na FS
#' @author Luiz Paulo T. Gonçalves
#' @details A função é dependente das funções get_id e get_tree

# rm(list = ls())

token_dev = c(
  'Content-Type' = 'application/json',
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlpXYkhLcUtMeGxIVDdNX2lpbHVLVSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImwudGF2YXJlc0A0aW50ZWxsaWdlbmNlLmNvbS5iciIsImlzcyI6Imh0dHBzOi8vZGV2ZWxvcG1lbnQtNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjQyNzFhZGIwMTc4ZjY4MDg3MTFhYWUwIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly9kZXZlbG9wbWVudC00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODQ5MzQ2NDQsImV4cCI6MTY4NTAyMTA0NCwiYXpwIjoiUGx4STk0T0dsVFQ1Zk9pYklhQUV0cU05MWh0OVRldFQiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.XK6x6a0v5f3ZlTbJ4EgzACxn-vTKyLjFT6Jh9-UcScECptR-amGSIRVmP1iiOdTyY1iC5YlyZsp7IVhjD5-ZBKaKs23MumNxfptTj0w3Zq074o8RO5oQ8CiWYLR5Y_vRrU3jpxempQwPjy0SZ1BPvb1Ca4wHCCzEHRrP-Q-yt7ZWpP44ZFBRMhywtJaPzlums9XMPTKsvFrLtxWtEeLyCSOCOVplHttik17zQ6MxHO5H-e-rt7EIzpFcOHOTkTBVYUrlcTqyOTiAVB_wH2-o696k2gKT-NDU0OGFVn_Nf_iZDGCbV0iSX-clSwvOavRkzb4zLPH-Rgc4b26paDTRHA'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Testando Função ---------------------------------------------------------------------
# Se modify_ind = TRUE, alterar o indicador solicitado

teste = modify_indicator(modify_ind = TRUE,
                         indicator = "BRINR0002",
                         access_type = "default",
                         name_en = "teste",
                         name_pt = "TestandoFuncaoEnvio",
                         short_en = "teste",
                         short_pt = "teste",
                         source_en = "teste",
                         source_pt = "teste",
                         description_en = "teste",
                         description_pt = "teste",
                         description_full_en = "teste",
                         description_full_pt = "teste",
                         node_en = "Brazil",
                         node_pt = "Brasil",
                         token = token_dev,
                         url = url_dev)



