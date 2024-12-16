defmodule VChatServer.Security do
  @moduledoc """
  Module responsible for encoding and decoding messages
  """

  alias VChatServer.Models.User

  @server_pub "#{:code.priv_dir(:v_chat_server)}/server/public.pem"

  # TODO: Atm we are passing in username, we want to find a better way
  def encrypt(message) when is_binary(message) do
    with {:ok, public_key_pem} <- __MODULE__.FileReader.get_public_key(@server_pub),
         {:ok, public_key} <- X509.PublicKey.from_pem(public_key_pem) do
      message
      |> :public_key.encrypt_public(public_key)
      |> Base.encode64()
    end
  end

  def encrypt(message, username) when is_binary(message) do
    with {:ok, %User{pub_key: pub_key}} <- VChatServer.Workflow.User.get_user(username),
         public_key_pem = __MODULE__.FileReader.wrap_rsa_public_key(pub_key),
         {:ok, public_key} <- X509.PublicKey.from_pem(public_key_pem) do
      message
      |> :public_key.encrypt_public(public_key)
      |> Base.encode64()
    end
  end

  def decrypt(message) when is_binary(message) do
    normalized = String.replace(message, "\n", "")

    with {:ok, encrypted} <- Base.decode64(normalized),
         {:ok, private_key_pem} <- __MODULE__.FileReader.get_private_key(),
         {:ok, private_key} <- X509.PrivateKey.from_pem(private_key_pem) do
      :public_key.decrypt_private(encrypted, private_key)
    end
  end
end
