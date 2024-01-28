"""empty message

Revision ID: 29381d24ec31
Revises: 9be38fc16ce9
Create Date: 2022-03-18 12:35:47.300705

"""
from alembic import op
import sqlalchemy as sa

import app.helpers.db_set_type


# revision identifiers, used by Alembic.
revision = '29381d24ec31'
down_revision = '9be38fc16ce9'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('recipe', sa.Column('planned_days', app.helpers.db_set_type.DbSetType(), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('recipe', 'planned_days')
    # ### end Alembic commands ###
