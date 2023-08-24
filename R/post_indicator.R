#' @title Enviar indicadores para a FS
#'
#' @name post.indicator
#'
#' @description A função busca enviar/criar novos indicadores na FS
#'
#' @param name_en representa o nome do indicador em inglês;
#' @param name_pt representa o nome do indicador em português;
#' @param short_en representa o nome curto em inglês;
#' @param short_pt representa o nome curto em português;
#' @param source_en representa a fonte/origem dos dados em inglês;
#' @param source_pt representa a fonte/origem dos dados em português;
#' @param description_en representa a descrição do indicador em inglês;
#' @param description_pt representa a descrição do indicador em português;
#' @param description_full_en representa a descrição completa em inglês;
#' @param description_full_pt representa a descrição completa em português;
#' @param country representa o país dos dados presente no indicador;
#' @param sector representa o setor no qual o indicador se insere;
#' @param acess_group representa o grupo no qual o indicador está;
#' @param id_node é um data.frame com os nodes e ids de cada node do indicador.
#'
#'
#' @author Luiz Paulo Tavares Gonçalves
#'
#' @details Caso já exista o indicador na FS, a função irá criar o mesmo indicador, porém com numeração diferente.
#'
#'
#' @return O retorno é um dataframe com todos os indicadores criados/enviados para a FS
#' @examples
#' \dontrun{
#'
#' send_indicadores = post.indicator(access_type = default,
#'                                  indicator_code = ARGDP0050,
#'                                  name_en = "ARG - Exports of Goods",
#'                                  name_pt = "ARG - Exportações de Bens",
#'                                  short_en = "Export. Goods",
#'                                  short_pt = "Exp. Bens",
#'                                  source_en = "Indec",
#'                                  source_pt = "Indec",
#'                                  description_en = "....",
#'                                  description_pt = "...",
#'                                  description_full_en = "...",
#'                                  description_full_pt = "...",
#'                                  country = "AR",
#'                                  sector = "BOP",
#'                                  acess_group = "Geral",
#'                                  node_en = "Argetina",
#'                                  node_pt = "Argentina")
#' }
#'
#' @export

post.indicator = function(access_type = as.character(),
                          access_group = as.character(),
                          indicator = as.character(),
                          name_en = as.character(),
                          name_pt = as.character(),
                          short_en = as.character(),
                          short_pt = as.character(),
                          source_en = as.character(),
                          source_pt = as.character(),
                          description_en = as.character(),
                          description_pt = as.character(),
                          description_full_en = as.character(),
                          description_full_pt = as.character(),
                          country = as.character(),
                          sector = as.character(),
                          node_en = as.character(),
                          node_pt = as.character(),
                          type_send, #ou PUT
                          token = token,
                          proj_owner,
                          url = url){
  
  send_fs <- body_indicator(indicator, access_type, access_group, name_en, name_pt, 
                            short_en, short_pt, source_en, source_pt, description_en, description_pt, 
                            description_full_en, description_full_pt, country, sector, 
                            node_en, node_pt, proj_owner)
  
  if(type_send == 'POST') {
    url_to_send <- paste0(url,"api/v1/indicators")
  } else if (type_send == 'PUT') {
    url_to_send <- paste0(url,"api/v1/indicators/", indicator)
  }
  
  sends_indicators = httr::VERB(type_send,
                                url = url_to_send,
                                body = send_fs$body_json[1],
                                httr::add_headers(token))
  
  if(httr::content(sends_indicators, 'text') != "{\"message\":\"The resource already exists.\"}") {
    print(httr::content(sends_indicators, 'text'))
    return(httr::content(sends_indicators)$message)
  } else {
    return(httr::content(sends_indicators)$message)
  }
}




