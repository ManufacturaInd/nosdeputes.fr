<?php

/**
 * ParlementairePhoto
 * 
 * This class has been auto-generated by the Doctrine ORM Framework
 * 
 * @package    cpc
 * @subpackage model
 * @author     Your name here
 * @version    SVN: $Id: Builder.php 7490 2010-03-29 19:53:27Z jwage $
 */
class ParlementairePhoto extends BaseParlementairePhoto
{
  public function setPhoto($p) {
    return $this->_set('photo', base64_encode($p));
  }
  public function getPhoto() {
    return base64_decode($this->_get('photo'));
  }
  public function save(Doctrine_Connection $c = null) {
    return parent::save($c);
  }
}
