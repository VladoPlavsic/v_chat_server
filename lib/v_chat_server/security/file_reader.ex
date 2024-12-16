defmodule VChatServer.Security.FileReader do
  @moduledoc """
    Module responsible for safe reading files
    This will contain storage for user-cert
  """

  @pub_key_path "#{:code.priv_dir(:v_chat_server)}/server/public.pem"
  @priv_key_path "#{:code.priv_dir(:v_chat_server)}/server/private.pem"

  def get_private_key(path \\ @priv_key_path) do
    if File.exists?(path) do
      {:ok, File.read!(path)}
    else
      {:error, :no_private_key}
    end
  end

  def get_public_key(path \\ @pub_key_path) do
    if File.exists?(path) do
      {:ok, File.read!(path)}
    else
      {:error, :no_public_key}
    end
  end

  def get_public_key!(path \\ @pub_key_path) do
    case get_public_key(path) do
      {:ok, key} -> key
      {:error, error} -> raise(error)
    end
  end

  def strip_rsa_public_key(key) do
    key
    |> String.replace("-----BEGIN PUBLIC KEY-----", "")
    |> String.replace("-----END PUBLIC KEY-----", "")
  end

  def wrap_rsa_public_key(key) do
    "-----BEGIN PUBLIC KEY-----\n" <>
      key <>
      "\n" <>
      "-----END PUBLIC KEY-----"
  end
end
