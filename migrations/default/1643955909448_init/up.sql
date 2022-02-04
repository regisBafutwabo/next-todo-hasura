SET check_function_bodies = false;
CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE TABLE public.todo (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    deleted_at timestamp with time zone,
    description text
);
COMMENT ON TABLE public.todo IS 'todos table';
CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    todo_id uuid NOT NULL
);
ALTER TABLE ONLY public.todo
    ADD CONSTRAINT todo_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
CREATE TRIGGER set_public_todo_updated_at BEFORE UPDATE ON public.todo FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_todo_updated_at ON public.todo IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_todo_id_fkey FOREIGN KEY (todo_id) REFERENCES public.todo(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
