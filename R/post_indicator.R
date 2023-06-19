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
                          indicator_code = as.character(),
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
                          token = token,
                          url = url){
  
  body = '{
 "access_type": "jesus",
  "indicator_code": "i_code",
  "name": {
    "en-us": "name_en",
    "pt-br": "name_pt"
  },
  "short_name": {
    "en-us": "short_en",
    "pt-br": "short_pt"
  },
  "source": {
    "en-us": "source_en",
    "pt-br": "source_pt"
  },
  "description": {
    "en-us": "description_en",
    "pt-br": "description_pt"
  },
  "description_full": {
    "en-us": "description_full_en",
    "pt-br": "description_full_pt"
  },
  "country": "countrys",
  "sector": "sectores",
  "access_group": "groups",
  "is_active": true,
  "tree": [
    {
      "id": "id_one",
      "node": "node_one",
      "name": {
        "en-us": "name_one_tree_en",
        "pt-br": "name_one_tree_pt"
      }
    },
    {
      "id": "id_two",
      "node": "node_two",
      "name": {
        "en-us": "name_two_tree_en",
        "pt-br": "name_two_tree_pt"
      }
    },
    {
      "id": "id_three",
      "node": "node_three",
      "name": {
        "en-us": "name_three_tree_en",
        "pt-br": "name_three_tree_pt"
      }
    },
    {
      "id": "id_four",
      "node": "node_four",
      "name": {
        "en-us": "name_four_tree_en",
        "pt-br": "name_four_tree_pt"
      }
    },
    {
      "id": "id_five",
      "node": "node_five",
      "name": {
        "en-us": "name_five_tree_en",
        "pt-br": "name_five_tree_pt"
      }
    },
    {
      "id": "id_six",
      "node": "node_six",
      "name": {
        "en-us": "name_six_tree_en",
        "pt-br": "name_six_tree_pt"
      }
    },
    {
      "id": "id_seven",
      "node": "node_seven",
      "name": {
        "en-us": "name_seven_tree_en",
        "pt-br": "name_seven_tree_pt"
      }
    }
  ]
}';
  
  input <- tibble::tibble(access_type = access_type,
                          access_group = access_group,
                          indicator_code = indicator_code,
                          name_en = name_en,
                          name_pt = name_pt,
                          short_name_en = short_en,
                          short_name_pt = short_pt,
                          source_en = source_en,
                          source_pt = source_pt,
                          description_en = description_en,
                          description_pt = description_pt,
                          description_full_en = description_full_en,
                          description_full_pt = description_full_pt,
                          country = country,
                          sector = sector,
                          node_en = list(node_en),
                          node_pt = list(node_pt))
  
  if(is.na(node_en)) {
    return(300)
  }
  
  id_nodes = get.id(tree = get.tree(master_node = base::strsplit(input$node_en[[1]], ", ")[[1]][1],
                                    token = token,
                                    url = url),
                    node = input$node_en[[1]])
  
  if(id_nodes$id[1] == 500) {
    return(500)
  }
  
  id_nodes = tibble::tibble(node = c(id_nodes$node,
                                     rep("", 7-length(id_nodes$id))),
                            id = c(id_nodes$id,
                                   rep("", 7-length(id_nodes$id))))
  
  send_fs = input %>%
    dplyr::rowwise() %>%
    dplyr::mutate(body = body,
                  body_json = stringr::str_replace_all(body,
                                                       c("jesus" = access_type,
                                                         "i_code" = indicator_code,
                                                         "name_en" = name_en,
                                                         "name_pt" = name_pt,
                                                         "short_en" = short_en,
                                                         "short_pt" = short_pt,
                                                         "source_en" = source_en,
                                                         "source_pt" = source_pt,
                                                         "description_en" = description_en,
                                                         "description_pt" = description_pt,
                                                         "description_full_en" = description_full_en,
                                                         "description_full_pt" = description_full_pt,
                                                         "countrys" = country,
                                                         "sectores" = sector,
                                                         "groups" = access_group,
                                                         # Nodes, IDS - Parte das funções
                                                         "id_one" = id_nodes[1,]$id,
                                                         "node_one" = id_nodes[1,]$node,
                                                         "name_one_tree_en" = strsplit(input$node_en[[1]], ", ")[[1]][1],
                                                         "name_one_tree_pt" = strsplit(input$node_pt[[1]], ", ")[[1]][1],
                                                         "id_two" = id_nodes[2,]$id,
                                                         "node_two" = id_nodes[2,]$node,
                                                         "name_two_tree_en" = ifelse(id_nodes[2,]$id == "",
                                                                                     "", strsplit(input$node_en[[1]], ",")[[2]]),
                                                         "name_two_tree_pt" = ifelse(id_nodes[2,]$id == "",
                                                                                     "", strsplit(input$node_pt[[1]], ",")[[2]]),
                                                         "id_three" = id_nodes[3,]$id,
                                                         "node_three" = id_nodes[3,]$node,
                                                         "name_three_tree_en" = ifelse(id_nodes[3,]$id == "",
                                                                                       "", strsplit(input$node_en[[1]], ",")[[3]]),
                                                         "name_three_tree_pt" = ifelse(id_nodes[3,]$id == "",
                                                                                       "", strsplit(input$node_pt[[1]], ",")[[3]]),
                                                         "id_four" = id_nodes[4,]$id,
                                                         "node_four" = id_nodes[4,]$node,
                                                         "name_four_tree_en" = ifelse(id_nodes[4,]$id == "",
                                                                                      "", strsplit(input$node_en[[1]], ",")[[4]]),
                                                         "name_four_tree_pt" = ifelse(id_nodes[4,]$id == "",
                                                                                      "", strsplit(input$node_pt[[1]], ",")[[4]]),
                                                         "id_five" = id_nodes[5,]$id,
                                                         "node_five" = id_nodes[5,]$node,
                                                         "name_five_tree_en" = ifelse(id_nodes[5,]$id == "",
                                                                                      "", strsplit(input$node_en[[1]], ",")[[5]]),
                                                         "name_five_tree_pt" = ifelse(id_nodes[5,]$id == "",
                                                                                      "", strsplit(input$node_pt[[1]], ",")[[5]]),
                                                         "id_six" = id_nodes[6,]$id,
                                                         "node_six" = id_nodes[6,]$node,
                                                         "name_six_tree_en" = ifelse(id_nodes[6,]$id == "",
                                                                                      "", strsplit(input$node_en[[1]], ",")[[6]]),
                                                         "name_six_tree_pt" = ifelse(id_nodes[6,]$id == "",
                                                                                      "", strsplit(input$node_pt[[1]], ",")[[6]]),
                                                         "id_seven" = id_nodes[7,]$id,
                                                         "node_seven" = id_nodes[7,]$node,
                                                         "name_seven_tree_en" = ifelse(id_nodes[7,]$id == "",
                                                                                     "", strsplit(input$node_en[[1]], ",")[[7]]),
                                                         "name_seven_tree_pt" = ifelse(id_nodes[7,]$id == "",
                                                                                     "", strsplit(input$node_pt[[1]], ",")[[7]])
                                                         
                                                         )),
                  url = paste0(url,"api/v1/indicators")) %>% 
    dplyr::select(-body)
  
  
  for (i in 1:length(send_fs$body_json)) {
    
    sends_indicators = httr::VERB("POST",
                                  url = send_fs$url[i],
                                  body = send_fs$body_json[i],
                                  httr::add_headers(token))
    
    if(httr::content(sends_indicators, 'text') != a) {
      return(sends_indicators$status_code)
    } else {
      return(200)
    }
  }
}



