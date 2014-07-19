defmodule Crawler.HrefExtractor do

	def extract_hrefs(html) do
		tree = :mochiweb_html.parse(html)
		results = :mochiweb_xpath.execute('//a/@href', tree)
	end

end