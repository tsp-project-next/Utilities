use pnext;
delimiter //

create table lobby (
	code char(4),
    playlist_uri varchar(200) not null,
    maxsize int not null,
    currentsize int not null,
    primary key(Code)
) //

create table users (
	user_id char(4),
    code char(4),
    is_host boolean not null,
    primary key(user_id),
    foreign key(code) references lobby(code)
) //

create procedure addUser(user_id char(4), code char(4), is_host boolean)
begin
	insert into users values(user_id, code, is_host);
end //

create procedure addLobby(code char(4), playlist_uri varchar(200))
begin
	insert into lobby values(code, playlist_uri, 20, 0);
end //

create procedure removeLobby(lCode char(4))
begin
	delete from lobby where code = lCode;
end //

create procedure removeUser(user_id char(4), code char(4), is_host boolean)
begin
	declare host boolean;
    select is_host into host from users where users.user_id = user_id;
    if host = 1 then
		delete from users where users.user_id = user_id;
        call removeLobby(code);
	else
		delete from users where users.user_id = user_id;
	end if;
end //

create trigger lobbyPlus after insert on users for each row
begin
	update lobby set currentsize = currentsize + 1
    where code = NEW.code;
end //

create trigger lobbyMinus after delete on users for each row
begin
	update lobby set currentsize = currentsize - 1
    where code = OLD.code;
end //

delimiter //

drop procedure editUser //

create procedure editUser(user_id char(4), code char(4), is_host boolean)
begin 
	update users set code = code, is_host = is_host where user_id = user_id;
end //

create trigger delLobby after delete on users for each row
begin 
	delete from lobby where code = OLD.code;
end //

create trigger lobbyMinus after delete on users for each row
begin 
	declare host boolean;
    select is_host into host from users where user_id = OLD.user_id;
    if host = 1 then
		call removeLobby(OLD.code);
	else
		update lobby set currentsize = currentsize - 1;
	end if;
end //

drop trigger lobbyMinus //

drop procedure removeUser //

create procedure removeUser(user_id char(4))
begin 
	delete from users where user_id = user_id;
end //