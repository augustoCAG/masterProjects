import csv
from datetime import datetime


lists = []
#lendo o arquivo csv original e armazenando em uma lista
with open('time_series_covid19_confirmed_global.csv') as f:
  reader = csv.reader(f)
  for row in reader:
    if row ==[]: ## Retirando as linhas que não contêm nada
      pass
    else:
      lists.append(row)

for sublist in lists:
    if sublist[1] == "Burma":
        sublist[1] = "Myanmar"
    if sublist[1] == "Congo (Brazzaville)":
        sublist[1] = "Rep Congo"
    if sublist[1] == "Congo (Kinshasa)":
        sublist[1] = "Dem Rep Congo"
    if sublist[1] == "Cote d'Ivoire":
        sublist[1] = "Cote dIvoire"
    if sublist[1] == "Korea, South":
        sublist[1] = "South Korea"
    if sublist[1] == "US":
        sublist[1] = "United States"
    if sublist[1] in ["Diamond Princess", "Holy See", "MS Zaandam" , "Taiwan*" ,"Western Sahara"]:
        lists.pop(lists.index(sublist))

for item in lists: ## tira as colunas que não serão necessárias  (lat e long)
    del(item[2:4])


#criando uma nova lista de listas e adicionanco somente os campos necessários ( dia, regiao, pais e casos)
newlist = []
for item in lists[1:]:
    for x in lists[0][2:]:
        temp = [datetime.strptime(x,'%m/%d/%y').isoformat()[0:10],item[0],item[1],item[lists[0].index(x)]]
        newlist.append(temp)



#escrevendo no novo arquivo csv
with open('formatted_covid_data.csv', 'w', newline='') as write:
  writer = csv.writer(write)
  for item in newlist:
     writer.writerow(item)


