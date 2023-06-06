#' @title Função Update Series 
#' @author Luiz Paulo T. 

modify_series <- function(sid, units_en, units_pt, token, url){
  
    # Guardando os inputs 
    input <- tibble::tibble(sid, units_en, units_pt)
  
# Campos da API para preenchiemnto  
  
body = '{
  "status": "active",
  "unit": {
    "en-us": "step_one",
    "pt-br": "step_two"
  }
}';

# Preenchendo o JSON - API 

send_fs = input %>%
          dplyr::mutate(indicador = substr(sid, 1,9)) %>%
          dplyr::rowwise() %>%
          dplyr::mutate(body = body,
                        body_json = stringr::str_replace_all(body, c("step_one" = units_en,
                                                                     "step_two" = units_pt)),
                        url = paste0(url, 'api/v1/indicators/', indicador, "/series/", sid)) %>% dplyr::select(-body)

# \Loop: modify_series 

for (i in 1:length(send_fs$body_json)) {
  
  path_series <- VERB("PATCH",
                      url = send_fs$url[i],
                      body = send_fs$body_json[i],
                      httr::add_headers(token))
  
  if(!is.null(path_series) | length(path_series) == 0){
    
    cat("Série", send_fs$sid[i], "atualizada com sucesso:", "\n")
    cat("\n")
    cat(httr::content(path_series, "text"))
    
  }else{
    
    stop("Erro!")
    
    }
  
  
  }

}

