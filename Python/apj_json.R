encoding = 'LVAUeByftALQomcWcJcM3yWFXCPlLRN94Ca5FzqsezuzZy7Pr2NdCP1LejoNBBvDfAE56ChqSAOuPaw7r9x9ZA%3D%3D'
decoding = 'LVAUeByftALQomcWcJcM3yWFXCPlLRN94Ca5FzqsezuzZy7Pr2NdCP1LejoNBBvDfAE56ChqSAOuPaw7r9x9ZA=='

install.packages("httr")
install.packages("jsonlite")

library(tidyverse)
library(httr)
library(jsonlite)

result <- GET('http://apis.data.go.kr/1790387/covid19CurrentStatusConfirmations/covid19CurrentStatusConfirmationsJson?serviceKey=LVAUeByftALQomcWcJcM3yWFXCPlLRN94Ca5FzqsezuzZy7Pr2NdCP1LejoNBBvDfAE56ChqSAOuPaw7r9x9ZA==')

type_data_format <- "json"
print(x=result)

result %>% 
  content(as = 'text', encoding='utf-8') %>%
  fromJSON() -> json

str(json)
json$response
