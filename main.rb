require 'nokogiri'
require 'sqlite3'
require 'open-uri'
require 'byebug'
require 'sanitize'

BASE_URL = "http://www.tudogostoso.com.br"

def initDb
  @db = SQLite3::Database.open 'tudo_gostoso.db'
end

def getCategories (url)
  doc = Nokogiri::HTML(open(url))

  return doc.css(".header li>a").map do |el|
    BASE_URL + el.attributes['href'].value
  end
end

def getRealUrl (url)
  doc = Nokogiri::HTML(open(url))
  links = doc.css(".category a")[0]
  if (links == nil)
    return url
  else
    return BASE_URL + links.attributes['href'].value
  end
end

def getReceitas (url)
  doc = Nokogiri::HTML(open(url))
  nx = doc.css("a.next")
  if nx != nil
    nx = nx[0].attributes['href']
  end

  return doc.css(".content .listing li>a").map do |el|
    BASE_URL + el.attributes['href'].value
  end, nx
end

def processaReceita (url)
  p "processing: " + url
  if (url == BASE_URL)
    p "ignoring"
    return
  end

  doc = Nokogiri::HTML(open(url))

  if (doc.css(".page-title h1").children[0] == nil)
    byebug
  end
  nome = doc.css(".page-title h1").children[0].text.gsub(/\n/, '')
  texto = Sanitize.fragment(doc.css(".instructions .instructions"))
  texto.lstrip!.rstrip!

  @db.execute("insert into receitas (nome, receita) values (?, ?)", nome, texto)
  rec_id = @db.get_first_value("select id from receitas where nome=?", nome)

  doc.css(".ingredients .recipelist li>span").each do |el|
    inp = el.children.text.gsub(/\n/, '')
    m = inp.match(/^\d( +)/)
    if m
      ingr = inp.sub(m.to_s, '')
      qtd = inp.rstrip.to_i
    else
      ingr = inp
      qtd = 1
    end

    ing_id = @db.get_first_value("select id from ingredientes where nome=?", ingr)
    if ing_id == nil
      @db.execute("insert into ingredientes (nome) values (?)", ingr)
      ing_id = @db.get_first_value("select id from ingredientes where nome=?", ingr)
    end

    @db.execute("insert into relate_ingrediente_receita (ingrediente_id, receita_id, quantidade) values (?, ?, ?)", ing_id, rec_id, qtd)
  end
end

begin
  initDb

  categories = getCategories(BASE_URL)

  categories.each do |cat|
    tospec = cat
    while (tospec) do
      receitas, tospec = getReceitas(getRealUrl(tospec))
      receitas.each do |rec|
        processaReceita(rec)
      end
    end
  end

  @db.close if @db
end
