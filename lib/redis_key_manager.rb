module RedisKeyManager

  # Set of a team's members
  def team_users(team_id)
    "team:members:#{team_id}"
  end

  # A list of teammates that a user has been paired with before
  # where the front of the list is the least recent pairing
  def user_pairings(user_id)
    "user:pairings:#{user_id}"
  end

  # A list of teammates that a user has not been paired with before
  # Probably because it's a new teammate
  def user_non_paired_teammates(user_id)
    "user:non:pairings:#{user_id}"
  end

end
