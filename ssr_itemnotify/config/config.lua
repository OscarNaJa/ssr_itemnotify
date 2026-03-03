Config = {}

Config.URL_NUI_Images = "nui://nc_inventory/html/img/items/" -- ที่อยู่ของรูปภาพไอเทม (กำหนดตามสคิปกระเป๋าที่ใช้อยู่)
Config.TimeOut = 5000 * 1000 -- กำหนดเวลาให้แจ้งเตือนหาย (ตัวอย่างนี้ตั้งไว้ 2วินาที)

-- ตำแหน่งการแสดงแจ้งเตือน (มีให้เลือก 2 รูปแบบ)
-- layout-uptodown = บนลงล่าง | -- layout-downtoup = ล่างขึ้นบน
Config.Layout = 'layout-downtoup'

-- true = แจ้งเตือนเมื่อถือ/สลับอาวุธอยู่ในมือ
Config.WeaponUse_Notify = true
-- true = แจ้งเตือนเมื่อได้รับอาวุธเข้าตัว (esx:addWeapon)
Config.WeaponAdd_Notify = true
-- true = แจ้งเตือนเมื่ออาวุธถูกเอาออกจากตัว (esx:removeWeapon)
Config.WeaponRemove_Notify = true

-- Prefix
Config.Prefix = {
    added = 'Added',
    remove = 'Removed',
    use_weapon = 'Use'
}

-- สำหรับคนที่ใช้ es_extended ตัวใหม่ตั้งค่า Config.es_extended_old = false เพื่อปิดใช้งานในส่วนที่ไม่จำเป็น
Config.es_extended_old = false

-- ระบบความปลอดภัย: ตรวจจับการได้รับไอเทมผิดปกติและเตะออกทันที
Config.Security = {
    Enabled = true,

    -- เปิด/ปิดการตรวจจับรายหัวข้อ
    Checks = {
        SingleGain = false,   -- ตรวจจับการได้ไอเทมครั้งเดียวเยอะผิดปกติ
        BurstEvents = true,  -- ตรวจจับความถี่การได้ไอเทมผิดปกติ
        BurstAmount = false   -- ตรวจจับยอดรวมไอเทมภายในช่วงเวลาผิดปกติ
    },

    -- ถ้าได้ไอเทมครั้งเดียวเกินจำนวนนี้ จะถูก flag
    MaxSingleGain = 100,

    -- ตรวจจับการได้ของถี่ผิดปกติในช่วงเวลา WindowSeconds
    WindowSeconds = 10,

    -- จำนวนครั้งที่ได้ของภายในหน้าต่างเวลาที่อนุญาต
    MaxGainEvents = 15,

    -- จำนวนไอเทมรวมที่ได้ภายในหน้าต่างเวลา
    MaxGainAmount = 200,

    -- การตอบสนองเมื่อถูกตรวจจับ
    Actions = {
        KickPlayer = true,
        SendWebhook = true
    },

    -- เหตุผลที่แสดงตอนเตะ
    KickReason = 'ระบบกันโปร : เนื่องจากคุณได้รับไอเท็มเข้าตัวเร็วผิดปกติ',

    -- Webhook Discord (เว้นว่าง = ไม่ส่ง)
    Webhook = {
        Url = 'https://discord.com/api/webhooks/1478165039146991616/QP3Go86U0qNuY8aIGHutAFxCx2w3DxZ_UNVNW8kuWeGHHhiX30q4AUYIefOXztkyDtsr',
        Name = 'SSR ItemNotify AC',
        AvatarUrl = '',
        Color = 15158332
    }
}
