defmodule MtgPula.TournamentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MtgPula.Tournaments` context.
  """

  @doc """
  Generate a tournament.
  """
  def tournament_fixture(attrs \\ %{}) do
    {:ok, tournament} =
      attrs
      |> Enum.into(%{
        current_round: 42,
        finished: true,
        name: "some name",
        number_of_rounds: 42
      })
      |> MtgPula.Tournaments.create_tournament()

    tournament
  end

  @doc """
  Generate a player.
  """
  def player_fixture(attrs \\ %{}) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        deck: "some deck",
        had_bye: true,
        opponents: [],
        points: 42
      })
      |> MtgPula.Tournaments.create_player()

    player
  end

  @doc """
  Generate a match.
  """
  def match_fixture(attrs \\ %{}) do
    {:ok, match} =
      attrs
      |> Enum.into(%{
        player_1_wins: 42,
        player_2_wins: 42,
        round: 42
      })
      |> MtgPula.Tournaments.create_match()

    match
  end
end
