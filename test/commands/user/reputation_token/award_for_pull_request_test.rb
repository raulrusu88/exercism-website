require "test_helper"

class User::ReputationToken::AwardForPullRequestTest < ActiveSupport::TestCase
  test "adds reputation token to pull request author when action is closed and merged" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert User::ReputationTokens::CodeContributionToken.where(user: user).exists?
  end

  test "reputation is awarded once per author per pull request" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    create :user_code_contribution_reputation_token, user: user

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_equal 2, user.reputation_tokens.size
  end

  test "reputation not awarded to pull request author if author is not known" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    refute User::ReputationToken.exists?
  end

  test "reputation not awarded to pull request author if pull request is closed but not merged" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_empty user.reputation_tokens
  end

  test "pull request without labels adds reputation token with default value" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_equal 10, user.reputation_tokens.last.value
  end

  test "pull request with reputation/contributed_code/regular label adds reputation token with default value" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/regular']
    user = create :user, handle: "User-22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_equal 10, user.reputation_tokens.last.value
  end

  test "pull request with reputation/contributed_code/minor label adds reputation token with lower value" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor']
    user = create :user, handle: "User-22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_equal 5, user.reputation_tokens.last.value
  end

  test "pull request with reputation/contributed_code/major label adds reputation token with higher value" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User-22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_equal 15, user.reputation_tokens.last.value
  end

  test "pull request with minor and major reputation labels adds reputation token for major reputation" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor', 'reputation/contributed_code/major']
    user = create :user, handle: "User-22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_equal 15, user.reputation_tokens.last.value
  end

  test "pull request ignores irrelevant labels" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = %w[bug duplicate]
    user = create :user, handle: "User-22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_equal 10, user.reputation_tokens.last.value
  end

  test "pull request with added label updates reputation value" do
    action = 'labeled'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/minor']
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_code_contribution_reputation_token,
      user: user,
      level: :regular,
      params: {
        repo: repo,
        pr_id: pr_id
      }

    assert_equal :regular, reputation_token.level # Sanity
    assert_equal 10, reputation_token.value # Sanity

    User::ReputationToken::AwardForPullRequest.(
      action, login,
      url: url, html_url: html_url, labels: labels,
      repo: repo, pr_id: pr_id, merged: merged
    )

    assert_equal 1, user.reputation_tokens.size
    assert_equal :minor, reputation_token.reload.level
    assert_equal 5, reputation_token.reload.value
  end

  test "pull request with changed label updates reputation value" do
    action = 'labeled'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_code_contribution_reputation_token, user: user, level: :minor,
                                                                        params: { repo: repo, pr_id: pr_id }

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_equal 1, user.reputation_tokens.size
    assert_equal 15, reputation_token.reload.value
  end

  test "pull request with removed label updates reputation value" do
    action = 'labeled'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"
    reputation_token = create :user_code_contribution_reputation_token, user: user, level: :minor,
                                                                        params: { repo: repo, pr_id: pr_id }

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_equal 1, user.reputation_tokens.size
    assert_equal 10, reputation_token.reload.value
  end

  test "pull request authors are not awarded reputation on labeled action when pull request has not been merged" do
    action = 'labeled'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = ['reputation/contributed_code/major']
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_empty user.reputation_tokens
  end

  test "pull request authors are not awarded reputation on unlabeled action when pull request has not been merged" do
    action = 'unlabeled'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_empty user.reputation_tokens
  end

  test "pull request reviewers are awarded reputation on closed action when pull request is merged" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [
        { user: { login: "reviewer71" } },
        { user: { login: "reviewer13" } }
      ].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    reputation_token_1 = reviewer_1.reputation_tokens.last
    assert_equal 3, reputation_token_1.value

    reputation_token_2 = reviewer_2.reputation_tokens.last
    assert_equal 3, reputation_token_2.value
  end

  test "pull request reviewers are awarded reputation on closed action even when pull request is not merged" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = false
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer_1 = create :user, handle: "Reviewer-71", github_username: "reviewer71"
    reviewer_2 = create :user, handle: "Reviewer-13", github_username: "reviewer13"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [
        { user: { login: "reviewer71" } },
        { user: { login: "reviewer13" } }
      ].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    reputation_token_1 = reviewer_1.reputation_tokens.last
    assert_equal 3, reputation_token_1.value

    reputation_token_2 = reviewer_2.reputation_tokens.last
    assert_equal 3, reputation_token_2.value
  end

  test "pull request reviewers are not awarded reputation on labeled action" do
    action = 'labeled'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_empty reviewer.reputation_tokens
  end

  test "pull request reviewers are not awarded reputation on unlabeled action" do
    action = 'unlabeled'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    reviewer = create :user, handle: "Reviewer-71", github_username: "reviewer71"

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    assert_empty reviewer.reputation_tokens
  end

  test "pull request authors are not awarded reputation for reviewing their own pull request" do
    action = 'closed'
    login = 'user22'
    repo = 'exercism/v3'
    pr_id = 1347
    merged = true
    url = 'https://api.github.com/repos/exercism/v3/pulls/1347'
    html_url = 'https://github.com/exercism/v3/pull/1347'
    labels = []
    user = create :user, handle: "User-22", github_username: "user22"

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/v3/pulls/1347/reviews").
      to_return(status: 200, body: [
        { user: { login: 'user22' } }
      ].to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.(action, login,
      url: url, html_url: html_url, labels: labels, repo: repo, pr_id: pr_id, merged: merged)

    refute User::ReputationTokens::CodeReviewToken.where(user: user).exists?
  end
end
