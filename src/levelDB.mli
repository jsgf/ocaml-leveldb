(** Access to [leveldb] databases. *)

(** Errors (apart from [Not_found]) are notified with [Error s] exceptions. *)
exception Error of string

(** Database *)
type db

(** Batch write operations. *)
type writebatch

(** Open a leveldb database in the given directory. *)
val open_db :
  ?write_buffer_size:int ->
  ?max_open_files:int ->
  ?block_size:int -> ?block_restart_interval:int -> string -> db

(** Close the database. All further operations on it will fail.
  * Note that the database is closed automatically in the finalizer if you
  * don't close it manually. *)
val close : db -> unit

(** [get_approximate_size from_key to_key] returns the approximate size
  * on disk of the range comprised between [from_key] and [to_key]. *)
val get_approximate_size : db -> string -> string -> Int64.t

(** Retrieve a value. *)
val get : db -> string -> string option

(** Retrieve a value, raising [Not_found] if missing. *)
val get_exn : db -> string -> string

(** [put ?sync key value] adds (or replaces) a binding to the database.
  * @param sync whether to write synchronously (default: false) *)
val put : db -> ?sync:bool -> string -> string -> unit

(** [delete ?sync key] deletes the binding for the given key.
  * @param sync whether to write synchronously (default: false) *)
val delete : db -> ?sync:bool -> string -> unit

(** [mem db key] returns [true] iff [key] is present in [db]. *)
val mem : db -> string -> bool

(** [iter f db] applies [f] to all the bindings in [db] until it returns
  * [false], i.e.  runs [f key value] for all the bindings in lexicographic
  * key order. *)
val iter : (string -> string -> bool) -> db -> unit

(** Like {!iter}, but proceed in reverse lexicographic order. *)
val rev_iter : (string -> string -> bool) -> db -> unit

(** [iter_from f db start] applies [f key value] for all the bindings after
  * [start] (inclusive) until it returns false. *)
val iter_from : (string -> string -> bool) -> db -> string -> unit

(** [iter_from f db start] applies [f key value] for all the bindings before
  * [start] (inclusive) in reverse lexicographic order until [f] returns
  * [false].. *)
val rev_iter_from : (string -> string -> bool) -> db -> string -> unit

(** Batch operations applied atomically. *)
module Batch :
sig
  (** Initialize a batch operation. *)
  val make : unit -> writebatch

  (** [put writebatch key value] adds or replaces a binding. *)
  val put : writebatch -> string -> string -> unit

  (** [delete writebatch key] removes the binding for [key], if present.. *)
  val delete : writebatch -> string -> unit

  (** Apply the batch operation atomically.
    * @param sync whether to write synchronously (default: false) *)
  val write : db -> ?sync:bool -> writebatch -> unit
end