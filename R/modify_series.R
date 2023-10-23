#' @title Função Update Series
#' @author Luiz Paulo T.

modify_series <- function(sid, tipo_acesso = 'default', units_en, units_pt, token, url){

    # Guardando os inputs
    input <- tibble::tibble(sid, units_en, units_pt)

# Campos da API para preenchiemnto

body = '{
  "status": "active",
  "access_type": "step_one",
  "unit": {
    "en-us": "step_two",
    "pt-br": "step_three"
  }
}';

# Preenchendo o JSON - API

send_fs = input %>%
          dplyr::mutate(indicador = substr(sid, 1,9)) %>%
          dplyr::rowwise() %>%
          dplyr::mutate(body = body,
                        body_json = stringr::str_replace_all(body, c("step_two" = units_en,
                                                                     "step_three" = units_pt,
                                                                     "step_one" = tipo_acesso)),
                        url = paste0(url, 'api/v1/indicators/', indicador, "/series/", sid)) %>% dplyr::select(-body)

# \Loop: modify_series

for (i in 1:length(send_fs$body_json)) {

  path_series <- VERB("PATCH",
                      url = send_fs$url[i],
                      body = send_fs$body_json[i],
                      httr::add_headers(token_to_use))

    cat("Série:", send_fs$sid[i], "\n")
    cat("\n")
    cat(httr::content(path_series, "text"))
    cat("\n")
    cat("\n")

    return(path_series$status_code)
  }

}

get_sids <- function(url, token, indicators){

  all_series <- tibble()# para preenchimento

  for (indicator in indicators) {
    get_fs <- httr::VERB("GET",
                         url = paste0(url, "api/v1/indicators/", indicator, "/series?limit=3000"),
                         add_headers(token)) %>%
      httr::content("parsed")

    current_series <- tibble()
    for (i in seq_along(get_fs[["data"]])) {
      current_code <- get_fs[["data"]][[i]][["code"]]
      current_series <- dplyr::bind_rows(current_series,
                                         tibble(code = current_code))
    }

    all_series <- dplyr::bind_rows(all_series, current_series)
  }

  return(all_series)  # Retorna o data frame com todas as séries
}
