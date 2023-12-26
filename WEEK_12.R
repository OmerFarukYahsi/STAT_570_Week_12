library(tidyverse)
library(repurrrsive)
library(jsonlite)
x1 <- list(1:4, "a", TRUE)
x1

x2 <- list(a = 1:2, b = 1:3, c = 1:4)
x2

str(x1)

x3 <- list(list(1, 2), list(3, 4))
str(x3)


c(c(1,2),c(3,4))

x4 <- c(list(1, 2), list(3, 4))
str(x4)

x5 <- list(1, list(2,list(3, list(4, list(5)))))
View(x5)

df <-  tibble(
  x  = 1:2,
  y = c("a", "b"),
  z = list(list(1,2), list(3,4,5))
)
df

df |> 
  filter(x == 1)

df1 <- tribble(
  ~x, ~y,
  1, list(a = 11, b = 12),
  2, list(a = 21, b = 22),
  3, list(a = 31, b = 32),
)

df1 |> 
  unnest_wider(y)

df1 |> 
  unnest_wider(y, names_sep = "_")

df2 <- tribble(
  ~x, ~y,
  1, list(11,12),
  2, list(21,22),
  3, list(31,32),
)
df2

df2 |> 
  unnest_longer(y)


df6 <- tribble(
  ~x, ~y,
  "a", list(1,2),
  "b", list(3),
  "c", list(),
)
df6

df6 |> unnest_longer(y)

df4 <- tribble(
  ~x, ~y,
  "a", list(1),
  "b", list("a", TRUE, 5)
)
df4

df4 |> 
  unnest_longer(y)

library(jsonlite)


View(gh_repos)

repos <- tibble(json= gh_repos)

repos

repos |> 
  unnest_longer(json)

repos |> 
  unnest_longer(json) |> 
  unnest_wider(json)

repos |> 
  unnest_longer(json) |> 
  unnest_wider(json) |> 
  names() |> 
  head(10)

repos |> 
  unnest_longer(json) |> 
  unnest_wider(json) |> 
  select(id, full_name, owner, description)


repos |> 
  unnest_longer(json) |> 
  unnest_wider(json) |> 
  select(id, full_name, owner, description) |> 
  unnest_wider(owner, names_sep = "_")


chars <- tibble(json = got_chars)
chars


characters <- chars |> 
  unnest_wider(json) |> 
  select(id, name, gender, culture, born, died, alive)
characters


chars |> 
  unnest_wider(json) |> 
  select(id, where(is.list))


titles <- chars |> 
  unnest_wider(json) |> 
  select(id, titles) |> 
  unnest_longer(titles) |> 
  filter(titles != "") |> 
  rename(title=titles)
titles

locations <- gmaps_cities |> 
  unnest_wider(json) |> 
  select(-status) |> 
  unnest_longer(results) |> 
  unnest_wider(results)

locations |> 
  select(city, formatted_address, geometry) |> 
  unnest_wider(geometry) |> 
  unnest_wider(location)


locations |> 
  select(city, formatted_address, geometry) |> 
  unnest_wider(geometry) |> 
  # focus on the variables of interest
  select(!location:viewport) |>
  unnest_wider(bounds)


locations |> 
  select(city, formatted_address, geometry) |> 
  unnest_wider(geometry) |> 
  select(!location:viewport) |>
  unnest_wider(bounds) |> 
  rename(ne = northeast, sw = southwest) |> 
  unnest_wider(c(ne, sw), names_sep = "_")   

# Web scraping ------------------------------------------------------------


library(tidyverse)
library(rvest)

html <- read_html("http://rvest.tidyverse.org/")
html

html <- minimal_html(" <p>This is a paragraph</p> <ul> <li>This is a bulleted list</li> </ul> ") 

html

html <- minimal_html("
  <h1>This is a heading</h1>
  <p id='first'>This is a paragraph</p>
  <p class='important'>This is an important paragraph</p>
")

html |> html_elements("p")

html |> html_elements(".important")

html |> html_elements("b")
html |> html_element("b")


html <- minimal_html("

  <ul>

    <li><b>C-3PO</b> is a <i>droid</i> that weighs <span class='weight'>167 kg</span></li>

    <li><b>R4-P17</b> is a <i>droid</i></li>

    <li><b>R2-D2</b> is a <i>droid</i> that weighs <span class='weight'>96 kg</span></li>

    <li><b>Yoda</b> weighs <span class='weight'>66 kg</span></li>

  </ul>

  ")

characters <- html |>  html_elements("li")

characters

characters |>  html_element("b")

characters |>  html_elements(".weight")

characters |>  html_element("b") |> 
  html_text2()

characters |>  html_element(".weight") |> 
  html_text2()

html <- minimal_html(" <p><a href='https://en.wikipedia.org/wiki/Cat'>cats</a></p>; <p><a href='https://en.wikipedia.org/wiki/Dog'>dogs</a></p>; ") 

html |> 
  html_elements("p") |> 
  html_element("a") |> 
  html_attr("href")

html <- minimal_html("
  <table class='mytable'>
    <tr><th>x</th>   <th>y</th></tr>
    <tr><td>1.5</td> <td>2.7</td></tr>
    <tr><td>4.9</td> <td>1.3</td></tr>
    <tr><td>7.2</td> <td>8.1</td></tr>
  </table>
  ")
html |> 
  html_element(".mytable") |> 
  html_table()

url <- "https://rvest.tidyverse.org/articles/starwars.html"
html <- read_html(url)

section <- html |> html_elements("section")
section

section |> html_element("h2") |>  html_text2()

section |> html_element(".director") |> html_text2()

tibble(
  title = section |> 
    html_element("h2") |> 
    html_text2(),
  released = section |> 
    html_element("p") |> 
    html_text2() |> 
    str_remove("Released: ") |> 
    parse_date(),
  director = section |> 
    html_element(".director") |> 
    html_text2(),
  intro = section |> 
    html_element(".crawl") |> 
    html_text2()
)



# IMDB --------------------------------------------------------------------



url <- "https://web.archive.org/web/20220201012049/https://www.imdb.com/chart/top/"
html <- read_html(url)

table <- html |> 
  html_element("table") |> 
  html_table()
table


ratings <- table |>
  select(
    rank_title_year = `Rank & Title`,
    rating = `IMDb Rating`
  ) |> 
  mutate(
    rank_title_year = str_replace_all(rank_title_year, "\n +", " ")
  ) |> 
  separate_wider_regex(
    rank_title_year,
    patterns = c(
      rank = "\\d+", "\\. ",
      title = ".+", " +\\(",
      year = "\\d+", "\\)"
    )
  )
ratings

html |> 
  html_elements("td strong") |> 
  head() |> 
  html_attr("title")

ratings |>
  mutate(
    rating_n = html |> html_elements("td strong") |> html_attr("title")
  ) |> 
  separate_wider_regex(
    rating_n,
    patterns = c(
      "[0-9.]+ based on ",
      number = "[0-9,]+",
      " user ratings"
    )
  ) |> 
  mutate(
    number = parse_number(number)
  )
