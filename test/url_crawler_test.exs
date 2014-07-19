defmodule UrlCrawlerTest do
	use ExUnit.Case

	import Crawler.UrlCrawler, only: [ extract_hrefs: 1 ]

	def sample_xml do
		"""
		<html>
			<head>
				<title>Test page</title>
			</head>
			<body>
				<h1>Test</h1>
				<a href="facebook.com">Link</a>
				<p>Testing</p>
				<img src="img.jpg" alt="" />
				<a href="meck.html" class="link">Link</a>
			</body>
		</html>
		"""
	end

	test "parsing the title out" do
		results = extract_hrefs(sample_xml)
		assert results == ["facebook.com", "meck.html"]
	end
end