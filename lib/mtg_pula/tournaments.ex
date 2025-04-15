defmodule MtgPula.Tournaments do
  @moduledoc """
  The Tournaments context.
  """

  import Ecto.Query, warn: false
  alias MtgPula.Repo

  alias MtgPula.Tournaments.Tournament

  @doc """
  Returns the list of tournaments.

  ## Examples

      iex> list_tournaments()
      [%Tournament{}, ...]

  """
  def list_tournaments do
    Repo.all(Tournament)
  end

  @doc """
  Gets a single tournament.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_tournament!(123)
      %Tournament{}

      iex> get_tournament!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament!(id), do: Repo.get!(Tournament, id)

  @doc """
  Gets a tournament by join code.
  ## Examples

      iex> get_tournament_by_join_code("123456")
      %Tournament{}

      iex> get_tournament_by_join_code("123456")
      nil
  """
  def get_tournament_by_join_code(join_code), do: Repo.get_by(Tournament, join_code: join_code)

  @doc """
  Creates a tournament.

  ## Examples

      iex> create_tournament(%{field: value})
      {:ok, %Tournament{}}

      iex> create_tournament(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tournament(attrs \\ %{}) do
    %Tournament{}
    |> Tournament.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tournament.

  ## Examples

      iex> update_tournament(tournament, %{field: new_value})
      {:ok, %Tournament{}}

      iex> update_tournament(tournament, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tournament(%Tournament{} = tournament, attrs) do
    tournament
    |> Tournament.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tournament.

  ## Examples

      iex> delete_tournament(tournament)
      {:ok, %Tournament{}}

      iex> delete_tournament(tournament)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tournament(%Tournament{} = tournament) do
    Repo.delete(tournament)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tournament changes.

  ## Examples

      iex> change_tournament(tournament)
      %Ecto.Changeset{data: %Tournament{}}

  """
  def change_tournament(%Tournament{} = tournament, attrs \\ %{}) do
    Tournament.changeset(tournament, attrs)
  end

  alias MtgPula.Tournaments.Player

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(player_id) do
    player = get_player!(player_id)
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{data: %Player{}}

  """
  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end

  alias MtgPula.Tournaments.Match

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches do
    Repo.all(Match)
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id), do: Repo.get!(Match, id)

  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_played(attrs) do
    if attrs.player1_id || attrs.player2_id != nil do
      with player1 <- get_player!(attrs.player1_id),
           player2 when not is_nil(player2) <- get_player!(attrs.player2_id) do
        updated_player1 = %{opponents: [player2.id | player1.opponents]}
        updated_player2 = %{opponents: [player1.id | player2.opponents]}

        update_player(player1, updated_player1)
        update_player(player2, updated_player2)

        :ok
      else
        _ -> {:error, "One or both players not found"}
      end
    end
  end

  def create_match(attrs \\ %{}) do
    if attrs != %{} and attrs.player2_id != nil do
      update_played(attrs)
    end

    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{data: %Match{}}

  """
  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end

  @doc """
  Lists tournaments with their players
  ## Examples
  """

  def list_tournaments_with_players_and_users do
    Tournament
    |> Repo.all()
    |> Repo.preload(player: [:user])
  end

  @doc """
  Lists all players added to a certain tournament

  ## Examples

      iex> list_all_tournament_players(123)
      [%Player{}, ...]

  """
  def list_all_tournament_players(tournament_id) do
    try do
      query =
        from p in Player,
          where: p.tournament_id == ^tournament_id and p.dropped == false

      standings =
        Repo.all(query)
        |> Repo.preload(:user)

      {:ok, standings}
    rescue
      _e ->
        {:error, :not_found}
    end
  end

  @doc """
  Returns standings with tiebreakers and points
  ## Examples

      iex> standings_on_tournament(123)
      [%Player{}, ...]

  """
  def standings_on_tournament(tournament_id) do
    try do
      query =
        from p in Player,
          where: p.tournament_id == ^tournament_id and p.dropped == false

      standings = Repo.all(query)
      tournament = Repo.get!(Tournament, tournament_id)

      standings =
        standings
        |> calculate_tiebreakers(tournament)
        |> Enum.sort_by(&{&1.points, &1.omw, &1.gw, &1.ogp, &1.id}, :desc)

      {:ok, standings}
    rescue
      _e ->
        {:error, :not_found}
    end
  end

  def drop_player(player_id) do
    player = get_player!(player_id)
    update_player(player, %{dropped: true})
  end

  @doc """
  Calculates tiebreakers for a certain standings and tournament
  ## Examples

      iex> calculate_tiebreakers(standings, tournament)
      [%Player{}, ...]


  """
  def calculate_tiebreakers(standings, tournament) do
    new_standings =
      Enum.reduce(standings, [], fn x, acc ->
        # Skip this iteration if x.opponent array is empty and if player had bye

        if Enum.empty?(x.opponents) and x.had_bye do
          new_player =
            x
            |> Map.put(:omw, 33.00)
            |> Map.put(:gw, 0.00)
            |> Map.put(:ogp, 33.00)
            |> Map.put(:points, calculate_points(x))
            |> Repo.preload([:user])

          acc ++ [new_player]
        else
          gw = calculate_gw(x)
          omw = calculate_procentage_omw(x, tournament)
          ogp = calculate_ogp(x)
          points = calculate_points(x)

          new_player =
            x
            |> Map.put(:omw, omw)
            |> Map.put(:gw, gw)
            |> Map.put(:ogp, ogp)
            |> Map.put(:points, points)
            |> Repo.preload([:user])

          acc ++ [new_player]
        end
      end)

    new_standings
  end

  @doc """
  Calculates points for a player
  ## Examples

      iex> calculate_points(player)
      %Player{}

  """
  def calculate_points(player) do
    query_wins =
      from m in Match,
        where: m.winner_id == ^player.id,
        select: count()

    player_wins = Repo.one(query_wins)

    q =
      from m in Match,
        where: (m.player1_id == ^player.id or m.player2_id == ^player.id) and m.is_draw == true,
        select: count()

    player_draws = Repo.one(q)

    bye =
      if player.had_bye do
        3
      else
        0
      end

    points = player_wins * 3 + player_draws + bye

    changeset = Player.changeset(player, %{points: points})
    Repo.update(changeset)

    points
  end

  @doc """
  Calculates average opponents match win procentage from players list of opponents
  ## Examples

  """
  def calculate_procentage_omw(player, _tournament) do
    adds_up =
      Enum.reduce(player.opponents, [], fn y, acc ->
        {_tail, casted} = Ecto.UUID.cast(y)

        query = from w in Match, where: w.winner_id == ^casted, select: count()
        match_wins = Repo.one(query)

        q_matches =
          from m in Match,
            where: m.player1_id == ^casted or m.player2_id == ^casted,
            select: count()

        n_matches = Repo.one(q_matches)

        # Calculate procentage

        procentage = Float.round(match_wins / n_matches, 2) || 0.00
        # IO.inspect(procentage)

        # Ensure minimum procentage of 0.33
        procentage = if procentage < 0.33, do: 0.33, else: procentage

        # Accumulate the result
        acc ++ [procentage]
      end)

    procentage = Float.round(Enum.sum(adds_up) / Enum.count(adds_up) * 100, 2)
    procentage
  end

  @doc """
  Calculates average opponents game win procentage from each game win that appears on certain tournament


  """
  def calculate_gw(player) do
    # Ensure player_id is used as a string
    # IO.inspect(player.deck)
    player1_wins_query =
      from m in Match,
        where: m.player1_id == ^player.id,
        select: sum(m.player_1_wins)

    player2_wins_query =
      from m in Match,
        where: m.player2_id == ^player.id,
        select: sum(m.player_2_wins)

    player1_wins = Repo.one(player1_wins_query) || 0
    player2_wins = Repo.one(player2_wins_query) || 0

    total_wins = player1_wins + player2_wins

    total_games_query =
      from m in Match,
        where: m.player1_id == ^player.id or m.player2_id == ^player.id,
        select: sum(m.player_1_wins + m.player_2_wins)

    total_games = Repo.one(total_games_query) || 0
    # IO.inspect( total_games)
    # Calculate win percentage
    win_percentage =
      if total_games > 0 do
        Float.round(total_wins / total_games * 100, 2)
      else
        0
      end

    win_percentage
  end

  @doc """
  Calculates average opponents game win procentage from players list of opponents


  """
  def calculate_ogp(player) do
    adds_up =
      Enum.reduce(player.opponents, [], fn y, acc ->
        {_tail, casted} = Ecto.UUID.cast(y)
        opponent = Repo.one(from o in Player, where: o.id == ^casted)
        gw = calculate_gw(opponent)
        acc ++ [gw]
      end)

    procentage = Float.round(Enum.sum(adds_up) / Enum.count(adds_up), 2)
    procentage
  end

  @doc """
  Takes in tournament_id. Calculates current standings based on player performance.
  Updates the current_round, to match the round we are currently in. Returns pairings for the current round.


  """

  def pair_next_round(tournament_id) do
    tournament = get_tournament!(tournament_id)

    standings =
      if tournament.current_round > 1 and tournament.current_round do
        {:ok, standings} = standings_on_tournament(tournament_id)
        standings
      else
        query =
          from p in Player,
            where: p.tournament_id == ^tournament_id

        Repo.all(query)
      end

    tournament =
      case update_tournament(tournament, %{current_round: tournament.current_round + 1}) do
        {:ok, tournament} -> tournament
        {:error, _} -> nil
      end

    {tournament, make_pairings(standings, [])}
  end

  @doc """
  Takes in tournament_id. Pairs next round, through pair_next_round()
  (see pair_next_round/1) and creates matches in the database


  """

  def prepare_matches(tournament_id) do
    tournament = get_tournament!(tournament_id)

    if tournament.finished do
      {:error, :finished_tourney}
    else
      try do
        {tournament, paired} = pair_next_round(tournament_id)

        # Logic to check if tournament has finished after this round
        if tournament.current_round >= tournament.number_of_rounds do
          update_tournament(tournament, %{finished: true})
        end

        paired
        |> Enum.each(fn {player1, player2} ->
          params =
            if player2 != :bye do
              %{
                player1_id: player1.id,
                player2_id: player2.id,
                tournament_id: tournament_id,
                on_play_id: player1.id,
                round: tournament.current_round
              }
            else
              %{
                player1_id: player1.id,
                player2_id: nil,
                tournament_id: tournament_id,
                on_play_id: player1.id,
                round: tournament.current_round
              }
            end

          create_match(params)
        end)

        {:ok, tournament, paired}
      rescue
        _e ->
          {:error, :not_found}
      end
    end
  end

  @doc """
  Recursively uses find_pair, to pair players by their performance.
  If there is a uneven number of players it gives the player that
  already hasnt had a bye, a bye,
  if all players had a bye it takes the first player that cant be paired.
  It returns an array of tuples of match pairs.


  """

  def make_pairings([], pairings), do: pairings

  def make_pairings([player | rest], pairings) do
    case find_pair(player, rest) do
      {pair, remaining} ->
        make_pairings(remaining, [{player, pair} | pairings])

      nil ->
        # Reorder the list by rank (assuming player.points is the ranking criteria)
        sorted_rest = Enum.sort_by(rest, &{&1.points, &1.omw, &1.gw, &1.ogp}, :asc)

        # Find the next lowest-ranked player who hasn't had a bye
        {bye_player, remaining} =
          case Enum.find(sorted_rest, fn p -> not p.had_bye end) do
            # Fallback to the current player if all have had a bye
            nil -> {player, rest}
            found_player -> {found_player, List.delete(sorted_rest, found_player)}
          end

        {:ok, updated_player} = update_player(bye_player, %{had_bye: true})

        make_pairings(remaining, pairings ++ [{updated_player, :bye}])
    end
  end

  @doc """
      Goes through all the players that
      are left to match them to a player that hasnt been paired with already.

  """

  def find_pair(player, rest) do
    Enum.reduce_while(rest, nil, fn potential_opponent, _acc ->
      if Enum.member?(player.opponents, potential_opponent.id) do
        {:cont, nil}
      else
        {:halt, {potential_opponent, List.delete(rest, potential_opponent)}}
      end
    end)
  end

  @doc """

  Finds and returns the current round  matches
  """
  def current_matches(tournament_id) do
    try do
      tournament = get_tournament!(tournament_id)

      q =
        from m in Match,
          where: m.round == ^tournament.current_round and m.tournament_id == ^tournament_id,
          preload: [player1: :user, player2: :user]

      matches = Repo.all(q)

      {:ok, matches}
    rescue
      _e -> {:error, :not_found}
    end
  end
  def tournament_matches(join_code) do
    try do
      tournament = get_tournament_by_join_code(join_code)

      q =
        from m in Match,
          where:  m.tournament_id == ^tournament.id,
          preload: [player1: :user, player2: :user],
          order_by: [asc: m.round]
      matches = Repo.all(q)

      {:ok, matches}
    rescue
      _e -> {:error, :not_found}
    end
  end
end
