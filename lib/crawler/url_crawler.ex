require Record

defmodule Crawler.UrlCrawler do

	Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
	Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
	Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")


	def crawl_url(url) do
		:inets.start()
		:httpc.request('http://www.erlang.org')
	end

	def extract_hrefs(html) do
		tree = :mochiweb_html.parse(html)
		results = :mochiweb_xpath.execute('/html/body/a/@href', tree)
	end

end