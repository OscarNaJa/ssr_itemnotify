const inventorUrl = 'nui://Fxw_inventory/html/img/items/';
const activeNotifications = new Map();

$(function () {
    window.addEventListener('message', (event) => {
        if (event.data.action === 'notify') {
            const options = {
                label: event.data.label || 'ITEM NAME',
                name: event.data.name || event.data.label || 'unknown_item',
                count: Number(event.data.count) || 0,
                remaining: Number.isFinite(Number(event.data.remaining)) ? Number(event.data.remaining) : null,
                type: event.data.type,
                timeout: Number(event.data.timeout) || 5000,
                image: `${inventorUrl}${event.data.name}.png`
            };

            imageExists(options.image, (exists) => {
                if (!exists) options.image = 'no-image.png';
                sendNotify(options);
            });
            return;
        }

        if (event.data.type === 'clear') {
            clearNotificationByKey(event.data.number);
        }
    });
});

function imageExists(url, callback) {
    const img = new Image();
    img.onload = () => callback(true);
    img.onerror = () => callback(false);
    img.src = url;
}

function escapeAttr(value) {
    return String(value).replace(/[^a-zA-Z0-9_-]/g, '-');
}

function getNotifyKey(options) {
    return `${options.type}-${options.name}`;
}

function clearNotificationByKey(key) {
    const existing = activeNotifications.get(key);
    if (!existing) return;

    if (existing.timeoutRef) clearTimeout(existing.timeoutRef);
    existing.$element.remove();
    activeNotifications.delete(key);
}

function hideNotification(key) {
    const current = activeNotifications.get(key);
    if (!current) return;

    current.$element.addClass('hiding');

    setTimeout(() => {
        const entry = activeNotifications.get(key);
        if (!entry) return;
        entry.$element.remove();
        activeNotifications.delete(key);
    }, 220);
}

function scheduleRemove(key, timeout) {
    const notify = activeNotifications.get(key);
    if (!notify) return;

    if (notify.timeoutRef) clearTimeout(notify.timeoutRef);
    notify.timeoutRef = setTimeout(() => hideNotification(key), timeout);
}

function renderHeader(options, displayCount) {
    const moneyHeader = renderMoneyHeader(options, displayCount);
    if (moneyHeader) return moneyHeader;

    const prefix = options.type === 'added' ? 'ไอเทมได้เข้าตัว' : 'ไอเทมออกจากตัว';
    const countClass = options.type === 'added' ? 'added' : 'remove';
    return `${prefix} <span class="notification-count ${countClass}">${formatItemCount(displayCount)}</span> ชิ้น`;
}

function renderMoneyHeader(options, displayCount) {
    if (options.type !== 'added') return null;

    const moneyName = String(options.name || '').toLowerCase();
    const amount = `<span class="notification-count added">${formatItemCount(displayCount)}</span>`;

    if (moneyName === 'cash' || moneyName === 'money') {
        return `ได้รับเงินสด ${amount} บาท`;
    }

    if (moneyName === 'bank') {
        return `ธนาคารมีเงินเข้า ${amount} บาท`;
    }

    if (moneyName === 'black_money') {
        return `ได้รับเงินแดง ${amount} บาท`;
    }

    return null;
}

function isMoneyType(options) {
    const moneyName = String(options.name || '').toLowerCase();
    return moneyName === 'cash' || moneyName === 'money' || moneyName === 'bank' || moneyName === 'black_money';
}

function renderRemaining(options, remaining) {
    const unit = isMoneyType(options) ? 'บาท' : 'ชิ้น';

    if (remaining === null || Number.isNaN(remaining)) {
        return `จำนวนคงเหลือ - ${unit}`;
    }

    return `จำนวนคงเหลือ ${formatItemCount(remaining)} ${unit}`;
}

function formatItemCount(value) {
    const numericValue = Number(value);
    if (!Number.isFinite(numericValue)) return '0';

    const sign = numericValue < 0 ? '-' : '';
    const absoluteValue = Math.abs(numericValue);

    if (absoluteValue >= 1000000) {
        return `${sign}${Math.floor(absoluteValue / 1000000)}M`;
    }

    if (absoluteValue >= 1000) {
        return `${sign}${Math.floor(absoluteValue / 1000)}K`;
    }

    return `${numericValue}`;
}

function buildNotificationHtml(options, displayCount, key, remaining) {
    const variant = options.type === 'added' ? 'added' : 'remove';

    return `
        <div class="notification ${variant}" id="item-${escapeAttr(key)}" data-notify-key="${key}">
            <div class="notification-card">
                <span class="notification-accent"></span>
                <div class="notification-main">
                    <p class="notification-head">${renderHeader(options, displayCount)}</p>
                    <p class="notification-text">ชื่อ : ${options.label}</p>
                    <p class="notification-sub">${renderRemaining(options, remaining)}</p>
                </div>
                <div class="notification-item-image"><img src="${options.image}" alt="${options.label}"></div>
            </div>
        </div>
    `;
}

function sendNotify(options) {
    if (options.type !== 'added' && options.type !== 'remove') return;

    const key = getNotifyKey(options);
    const existing = activeNotifications.get(key);

    if (existing) {
        existing.count += options.count;
        if (options.remaining !== null) {
            existing.remaining = options.remaining;
        }

        existing.$element.find('.notification-head').html(renderHeader(options, existing.count));
        existing.$element.find('.notification-text').text(`ชื่อ : ${options.label}`);
        existing.$element.find('.notification-sub').text(renderRemaining(options, existing.remaining));
        existing.$element.find('.notification-item-image img').attr('src', options.image).attr('alt', options.label);
        existing.$element.removeClass('hiding').addClass('pulse');
        setTimeout(() => existing.$element.removeClass('pulse'), 220);
        scheduleRemove(key, options.timeout);
        return;
    }

    const $element = $(buildNotificationHtml(options, options.count, key, options.remaining));
    $('#notification-container').append($element);

    activeNotifications.set(key, {
        $element,
        count: options.count,
        remaining: options.remaining,
        timeoutRef: null
    });

    scheduleRemove(key, options.timeout);
}
