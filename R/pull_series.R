#' @title Alterando aberturas/transformações presentes na FS
#' @name pull_series
#'
#' @description
#'
#' @author Luiz Paulo Tavares Gonçalves
#'
#' @return
#'
#' @examples
#' \dontrun{
#' }
#'
#' @export


pull_series = function(indicator = as.character(), 
                       token = as.character(), 
                       short_name_en = as.character(), 
                       short_name_pt = as.character()){

  
  input = tibble::tibble(indicator = indicator, 
                         name_en = short_name_en, 
                         name_pt = short_name_pt)
  
body = '{
  "is_active": true,
  "short_name": {
    "en-us": "step_um",
    "pt-br": "step_dois"
  }
}';
  
  pull_fs = input %>%
    dplyr::rowwise() %>%
    dplyr::mutate(body = body,
                  body_json = stringr::str_replace_all(body,
                                                       c("step_um" = name_en,
                                                         "step_dois" = name_pt)))
  
for (i in 1:length(pull_fs$indicator)) {
  
alterando <- httr::VERB("PUT", 
                   url = paste0("https://4i-featurestore-hmg-api.azurewebsites.net/api/v1/indicators/", pull_fs$indicator[i]),
                   body = pull_fs$body_json[i],
                   add_headers(token_homo))
  
  cat(content(alterando, 'text'))

  }

}









