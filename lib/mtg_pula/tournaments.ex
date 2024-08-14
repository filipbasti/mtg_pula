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
  def delete_player(%Player{} = player) do
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
  player1_id = attrs["player1_id"]
  player2_id = attrs["player2_id"]
  if player1_id || player2_id != nil do
  with player1 <- get_player!(player1_id),
       player2 when not is_nil(player2) <- get_player!(player2_id) do

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
    _ = update_played(attrs)

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
  @doc"""
  Pairing Logic
  """

  def list_tournaments_with_players_and_users do
    Tournament

    |> Repo.all()
    |>Repo.preload([player: [:user]])
  end
  def standings_on_tournament(tournament_id) do
    query = from p in Player,
      where: p.tournament_id == ^tournament_id,
      order_by: [desc: :points]
    standings = Repo.all(query)
    standings

  end
  def calculate_tiebreakers(standings, tournament) do
    new_standings = []

    new_standings = Enum.reduce(standings, [], fn x, acc ->
      gw = calculate_gw(x, tournament)
      omw= calculate_procentage_omw(x, tournament)


      ogp = calculate_ogp(x, tournament)
      new_player = x
      |>Map.put_new(:omw, omw)
      |>Map.put_new(:gw, gw)
      |>Map.put_new(:ogp, ogp)


      acc ++ [new_player]
    end)

    new_standings
  end

  def calculate_procentage_omw(player, tournament) do
    adds_up = Enum.reduce(player.opponents, [], fn y, acc ->
      {_tail, casted} = Ecto.UUID.cast(y)

      opponent = Repo.one(from o in Player, where: o.id == ^casted)

      query = from w in Match, where: w.winner_id == ^casted, select: count()
      match_wins = Repo.one(query) || 0  # Default to 0 if nil

      # Calculate procentage
      procentage =
        if tournament.current_round != 0 do
          match_wins / tournament.current_round
        else
          0
        end

      # Ensure minimum procentage of 0.33
      procentage = if procentage < 0.33, do: 0.33, else: procentage

      # Accumulate the result
      acc ++ [procentage]
    end)


    procentage = Enum.sum(adds_up)/ Enum.count(adds_up)*100
    procentage
  end
  def calculate_gw(player, tournament) do
    # Ensure player_id is used as a string

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
        select: sum(m.player_1_wins+m.player_2_wins)

    total_games = Repo.one(total_games_query)

    # Calculate win percentage
    win_percentage = if total_games > 0 do
      (total_wins / total_games) * 100
    else
      0
    end
    IO.inspect(win_percentage)
    win_percentage

  end

  def calculate_ogp(player, tournament) do
    adds_up = Enum.reduce(player.opponents, [], fn y, acc ->
      {_tail, casted} = Ecto.UUID.cast(y)
      opponent = Repo.one(from o in Player, where: o.id == ^casted)
    gw = calculate_gw(opponent, tournament)
    acc ++ [gw]

    end)
    procentage = Enum.sum(adds_up)/ Enum.count(adds_up)
    procentage
  end
end
