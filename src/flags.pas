unit flags;

interface

const
  { Нет флагов }
  NOF                = 0;

  { Флажки для монстров (всего 64) }
  // Возможности
  M_OPEN             = 1 shl 0;     // Может открывать двери
  M_FREEZE           = 1 shl 1;     // Не двигается
  M_NEUTRAL          = 1 shl 2;     // Монстр нейтрален к герою
  M_NAME             = 1 shl 3;     // Есть имя
  M_STAY             = 1 shl 4;     // Когда не видет цели просто стоит
  M_ALWAYSANSWERED   = 1 shl 5;     // Всегда отвечает на атаку
  M_DRUNK            = 1 shl 6;     // Пьяный
  M_HAVEITEMS        = 1 shl 7;     // Может держать вещи
  M_TACTIC           = 1 shl 8;     // Может применять тактику
  M_CLASS            = 1 shl 9;     // Определяем класс для монстра


  { Флажки для предметов }
  I_TWOHANDED        = 1 shl 0;     // Двуручное оружие

  { Флажки для напитков }
  L_NOSATURATION    =  1 shl 0;     // Напиток не насыщает
  L_WSATURATION     =  1 shl 1;     // Напиток насыщает вдвойне
  L_RANDOMPOWER     =  1 shl 2;     // Рандомная мощность эффекта напитка
  L_LITTLEHEAL      =  1 shl 3;     // Чуть-чуть лечит при употреблении
  L_WMASS           =  1 shl 4;     // Двойная масса напитка

implementation

end.
