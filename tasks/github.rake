task 'github:require-access-token' do
  unless $GITHUB_ACCESS_TOKEN
    warn("you must export JMESPATH_GITHUB_ACCESS_TOKEN")
    exit
  end
end

task 'github:release' do
  require 'octokit'

  gh = Octokit::Client.new(access_token: $GITHUB_ACCESS_TOKEN)

  repo = 'trevorrowe/jmespath.rb'
  tag_ref_sha = `git show-ref v#{$VERSION}`.split(' ').first
  tag = gh.tag(repo, tag_ref_sha)

  release = gh.create_release(repo, "v#{$VERSION}", {
    name: 'Release v' + $VERSION + ' - ' + tag.tagger.date.strftime('%Y-%m-%d'),
    body: tag.message.lines[2..-1].join,
    prerelease: $VERSION.match('rc') ? true : false,
  })

  gh.upload_asset(release.url, 'docs.zip',
    :content_type => 'application/octet-stream')

  gh.upload_asset(release.url, "jmespath-#{$VERSION}.gem",
    :content_type => 'application/octet-stream')

end
