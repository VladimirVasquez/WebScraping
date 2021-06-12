library(lubridate) 
library(rvest) 
library(devtools)
library(tidyverse) 
library(rlang) 
library(curl)

# set working directory 
setwd("C:/Users/4206230/Desktop/toi/cohoteling")

inicio <- today()
banco_precos_dia <- c()

qtd <- 100 #existe uma programação para calcular exatamente a quantidade aqui, mas ela não é relevante para este problema

banco_precos <- c()
# banco_precos_i <- c()

for(j in seq(0,qtd,25)){
  url_number <- j
  
  #buscando a pagina
  url <- curl(paste0('https://www.booking.com/searchresults.es.html?aid=397594&label=gog235jc-1DCAEoggI46AdIClgDaC-IAQGYAQq4ARfIAQzYAQPoAQH4AQKIAgGoAgO4ApbH7YMGwAIB0gIkNjk4M2VlZTYtNTkzMS00NmQ0LWJhOWItZTk2ZjQwNGM1ZTEz2AIE4AIB&sid=c6e0f004f1a58eaa95e9a3a2fb8fcdfb&tmpl=searchresults&ac_click_type=b&ac_position=0&checkin_month=5&checkin_monthday=3&checkin_year=2021&checkout_month=5&checkout_monthday=4&checkout_year=2021&class_interval=1&dest_id=-901202&dest_type=city&from_sf=1&group_adults=1&group_children=0&iata=SCL&label_click=undef&nflt=ht_id%3D204%3Bclass%3D3%3Bclass%3D4%3Bclass%3D5%3B&no_rooms=1&percent_htype_hotel=1&raw_dest_type=city&room1=A&sb_price_type=total&search_selected=1&shw_aparth=0&slp_r_match=0&src=index&srpvid=eb1c13320636006d&ss=Santiago%2C%20Regi%C3%B3n%20Metropolitana%2C%20Chile&ss_raw=santaigo&ssb=empty&top_ufis=1&rows=25&offset=',url_number), "rb")
  
  #lendo a pagina
  page <- read_html(url)
  
  #nome dos hoteis
  nomes_i <-page %>%
    html_nodes(".sr-hotel__name") %>%
    html_text()%>%
    {if(length(.) == 0) NA else .}
  
  #nome do quarto
  quarto_i <- page%>%
    html_nodes(".room_link strong ,  .sold_out_property") %>%
    html_text()%>%
    {if(length(.) == 0) NA else .}
  
  #*quando chega no dia 10/09 e o erro ocorre, eu paro o código, troco o código acima por quarto_i<- NA, espero baixar o mês de setembro e volto a baixar outubro em diante com o código acima - tudo manualmente*
  
  #precos
  precos_i <- page %>%
    html_nodes(".bui-price-display__value , .sold_out_property ") %>%
    html_text()%>%
    {if(length(.) == 0) NA else .}
  
  #construindo o banco de dados de cada página
  banco_precos_i <- data.frame(nomes_i, quarto_i, precos_i, stringsAsFactors = F)
  
  #alimentando o banco de dados de um dia
  banco_precos <- rbind(banco_precos ,banco_precos_i)
  
  #suspender execucao no R por 3 seg
  Sys.sleep(3)
}

hoteles = unique(banco_precos)
names(hoteles) = c("hotel", "habitación", "precio")
hoteles$hotel = gsub(pattern = '\n','', hoteles$hotel)
hoteles$precio = gsub(pattern = '\n','', hoteles$precio)
hoteles$precio = gsub(pattern = '\\.','', hoteles$precio)
hoteles$precio = gsub(pattern = '\\$','', hoteles$precio)
hoteles$precio = as.numeric(gsub(pattern = '^\\s+|\\s+$','', hoteles$precio))
hoteles = hoteles[order(hoteles$precio,decreasing=T),]
hoteles = hoteles[!is.na(hoteles$hotel),]
row.names(hoteles) <- NULL

# write.csv2(hoteles, "scrap.csv", row.names = F)


library(googlesheets4)
googlesheets4::sheets_sheets(ss = )

cohoteling_sheet = googlesheets4::read_sheet('https://docs.google.com/spreadsheets/d/1_WPwwnhcibZ57Z68WbC5F4O8ciNAikZUCQnh-2ospJ4/edit#gid=0')
