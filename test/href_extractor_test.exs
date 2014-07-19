defmodule HrefExtractorTest do
	use ExUnit.Case

	import Crawler.HrefExtractor, only: [ extract_hrefs: 1 ]

	def sample_xml do
		"""
		<!DOCTYPE html>
		<html>
			<head>
				<title>Test page</title>
			</head>
			<body>
				<h1>Test</h1>
				<div>
				<a href="facebook.com">Link</a>
				</div>
				<p>Testing</p>
				<img src="img.jpg" alt="" />
				<a href="meck.html" class="link">Link</a>
			</body>
		</html>
		"""
	end

	test "parsing the title out" do
		results = extract_hrefs(sample_xml)
		assert results == ["meck.html", "facebook.com"]
	end

end