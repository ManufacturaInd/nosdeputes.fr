<?php
if (!$user or !$user->photo)
{
  echo image_tag($style.'/avatar_citoyen.png', array('alt' => 'Avatar par d�faut'));
}
else
{
  echo '<a href="'.url_for('@citoyen?slug='.$user->slug).'"><img src="'.url_for('@photo_citoyen?slug='.$user->slug).'" alt="avatar" /></a>';
}